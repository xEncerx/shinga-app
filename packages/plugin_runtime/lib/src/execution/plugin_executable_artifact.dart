import 'dart:collection';
import 'dart:convert';
import 'dart:typed_data';

import 'package:analyzer/dart/analysis/features.dart';
import 'package:analyzer/dart/analysis/utilities.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/error/error.dart' as analyzer_error;
import 'package:path/path.dart' as p;
import 'package:plugin_protocol/plugin_protocol.dart';
import 'package:plugin_runtime/src/package/reader/reader.dart';

/// Immutable interpreted-Dart sources produced by structural inspection.
final class PluginExecutableArtifact {
  PluginExecutableArtifact._({
    required this.pluginId,
    required this.pluginVersion,
    required this.pluginApiVersion,
    required this.entryModuleId,
    required Map<String, String> sources,
    required Map<String, Uint8List> sourceBytes,
  }) : sources = UnmodifiableMapView(Map<String, String>.of(sources)),
       _sourceBytes = {
         for (final entry in sourceBytes.entries) entry.key: Uint8List.fromList(entry.value),
       };

  /// The manifest plugin identity bound to these exact bytes.
  final String pluginId;

  /// The manifest plugin version bound to these exact bytes.
  final String pluginVersion;

  /// The exact Plugin API version bound to these sources.
  final int pluginApiVersion;

  /// The normalized in-memory module ID used as the D4rt entry library.
  final String entryModuleId;

  /// The immutable normalized module-to-source map.
  final Map<String, String> sources;

  final Map<String, Uint8List> _sourceBytes;

  /// Returns defensive copies of the exact inspected source bytes.
  Map<String, Uint8List> copySourceBytes() => UnmodifiableMapView({
    for (final entry in _sourceBytes.entries) entry.key: Uint8List.fromList(entry.value),
  });
}

/// The result of closing and validating an interpreted source graph.
final class PluginArtifactBuildResult {
  /// Creates a result from immutable diagnostics and an optional [artifact].
  PluginArtifactBuildResult({
    required List<PackageDiagnostic> diagnostics,
    required this.artifact,
  }) : diagnostics = List.unmodifiable(diagnostics);

  /// Safe structural diagnostics in deterministic traversal order.
  final List<PackageDiagnostic> diagnostics;

  /// The artifact when every source and import passed preflight.
  final PluginExecutableArtifact? artifact;

  /// Whether an executable artifact was created without errors.
  bool get isValid => artifact != null && !diagnostics.hasErrors;
}

/// Reads and closes an interpreted-Dart module graph exactly once.
final class PluginExecutableArtifactBuilder {
  /// Creates a builder with inclusive source ceilings.
  const PluginExecutableArtifactBuilder({
    this.maxModuleBytes = PluginProtocolLimits.maxModuleSourceBytes,
    this.maxAggregateBytes = PluginProtocolLimits.maxAggregateSourceBytes,
  });

  /// Allowed SDK libraries for this milestone's ambient-I/O-free profile.
  static const Set<String> allowedDartLibraries = {
    'dart:async',
    'dart:collection',
    'dart:convert',
    'dart:core',
    'dart:math',
  };

  /// Maximum exact UTF-8 bytes in one module, inclusive.
  final int maxModuleBytes;

  /// Maximum exact UTF-8 bytes across the graph, inclusive.
  final int maxAggregateBytes;

  /// Builds from the bytes returned by [package] without any later re-read.
  Future<PluginArtifactBuildResult> build(
    PluginPackageReader package,
    PluginManifest manifest,
  ) async {
    if (maxModuleBytes <= 0 ||
        maxModuleBytes > PluginProtocolLimits.maxModuleSourceBytes ||
        maxAggregateBytes <= 0 ||
        maxAggregateBytes > PluginProtocolLimits.maxAggregateSourceBytes ||
        maxAggregateBytes < maxModuleBytes) {
      throw ArgumentError('Source limits must be positive and within protocol ceilings.');
    }

    final diagnostics = <PackageDiagnostic>[];
    final sources = <String, String>{};
    final sourceBytes = <String, Uint8List>{};
    final pendingPaths = Queue<String>()..add(manifest.entry.value);
    final visitedPaths = <String>{};
    final caseFoldedPaths = <String, String>{};
    final loadedPaths = <String>[];
    var aggregateBytes = 0;

    while (pendingPaths.isNotEmpty) {
      final relativePath = pendingPaths.removeFirst();
      if (!visitedPaths.add(relativePath)) continue;
      final caseFoldedPath = relativePath.toLowerCase();
      final existingCase = caseFoldedPaths[caseFoldedPath];
      if (existingCase != null && existingCase != relativePath) {
        diagnostics.add(
          PackageDiagnostic.error(
            code: 'plugin.source.module_case_collision',
            message: 'Dart module paths must remain distinct under portable case folding.',
            relativePath: relativePath,
          ),
        );
        continue;
      }
      caseFoldedPaths[caseFoldedPath] = relativePath;
      final bytes = await _readModule(package, relativePath, diagnostics);
      if (bytes == null) continue;
      if (await _aliasesLoadedModule(package, relativePath, loadedPaths, diagnostics)) {
        continue;
      }
      loadedPaths.add(relativePath);
      aggregateBytes += bytes.length;
      if (aggregateBytes > maxAggregateBytes) {
        diagnostics.add(
          PackageDiagnostic.error(
            code: 'plugin.source.aggregate_too_large',
            message: 'Plugin source must not exceed $maxAggregateBytes aggregate bytes.',
            relativePath: relativePath,
          ),
        );
        continue;
      }

      final source = _decodeStrictUtf8(bytes, relativePath, diagnostics);
      if (source == null) continue;
      final parseResult = parseString(
        content: source,
        throwIfDiagnostics: false,
        featureSet: FeatureSet.latestLanguageVersion(),
      );
      if (parseResult.errors.any(
        (error) => error.diagnosticCode.severity == analyzer_error.DiagnosticSeverity.ERROR,
      )) {
        diagnostics.add(
          PackageDiagnostic.error(
            code: 'plugin.source.invalid_dart',
            message: 'Module must contain structurally valid Dart source.',
            relativePath: relativePath,
          ),
        );
        continue;
      }

      final moduleId = _moduleId(manifest.id.value, relativePath);
      sources[moduleId] = source;
      sourceBytes[moduleId] = bytes;
      for (final directive in parseResult.unit.directives) {
        final importedPath = _validateDirective(
          directive,
          manifest.id.value,
          relativePath,
          diagnostics,
        );
        if (importedPath != null) pendingPaths.add(importedPath);
      }
    }

    if (diagnostics.hasErrors) {
      return PluginArtifactBuildResult(diagnostics: diagnostics, artifact: null);
    }
    final artifact = PluginExecutableArtifact._(
      pluginId: manifest.id.value,
      pluginVersion: manifest.version.value,
      pluginApiVersion: manifest.pluginApiVersion.value,
      entryModuleId: _moduleId(manifest.id.value, manifest.entry.value),
      sources: sources,
      sourceBytes: sourceBytes,
    );
    return PluginArtifactBuildResult(diagnostics: diagnostics, artifact: artifact);
  }

  Future<bool> _aliasesLoadedModule(
    PluginPackageReader package,
    String relativePath,
    List<String> loadedPaths,
    List<PackageDiagnostic> diagnostics,
  ) async {
    try {
      for (final loadedPath in loadedPaths) {
        if (await package.refersToSameEntry(loadedPath, relativePath)) {
          diagnostics.add(
            PackageDiagnostic.error(
              code: 'plugin.source.module_alias_forbidden',
              message: 'Distinct Dart module paths must not identify the same package file.',
              relativePath: relativePath,
            ),
          );
          return true;
        }
      }
      return false;
    } on PluginPackageReadException catch (error) {
      diagnostics.add(_moduleReadDiagnostic(error));
      return true;
    }
  }

  Future<Uint8List?> _readModule(
    PluginPackageReader package,
    String relativePath,
    List<PackageDiagnostic> diagnostics,
  ) async {
    try {
      final bytes = await package.readBytes(relativePath, maxBytes: maxModuleBytes);
      return Uint8List.fromList(bytes);
    } on PluginPackageReadException catch (error) {
      diagnostics.add(_moduleReadDiagnostic(error));
      return null;
    }
  }

  String? _decodeStrictUtf8(
    Uint8List bytes,
    String relativePath,
    List<PackageDiagnostic> diagnostics,
  ) {
    if ((bytes.length >= 3 && bytes[0] == 0xef && bytes[1] == 0xbb && bytes[2] == 0xbf) ||
        bytes.contains(0)) {
      diagnostics.add(
        PackageDiagnostic.error(
          code: bytes.contains(0) ? 'plugin.source.nul_forbidden' : 'plugin.source.bom_forbidden',
          message: bytes.contains(0)
              ? 'Dart source must not contain embedded NUL bytes.'
              : 'Dart source must not begin with a UTF-8 BOM.',
          relativePath: relativePath,
        ),
      );
      return null;
    }
    try {
      return utf8.decode(bytes, allowMalformed: false);
    } on FormatException {
      diagnostics.add(
        PackageDiagnostic.error(
          code: 'plugin.source.invalid_utf8',
          message: 'Dart source must be complete strict UTF-8.',
          relativePath: relativePath,
        ),
      );
      return null;
    }
  }

  String? _validateDirective(
    Directive directive,
    String pluginId,
    String importerPath,
    List<PackageDiagnostic> diagnostics,
  ) {
    final String? uriSource;
    if (directive is ImportDirective) {
      if (directive.deferredKeyword != null || directive.configurations.isNotEmpty) {
        return _forbiddenImport(importerPath, diagnostics);
      }
      uriSource = directive.uri.stringValue;
    } else if (directive is ExportDirective) {
      if (directive.configurations.isNotEmpty) {
        return _forbiddenImport(importerPath, diagnostics);
      }
      uriSource = directive.uri.stringValue;
    } else if (directive is PartDirective || directive is PartOfDirective) {
      return _forbiddenImport(importerPath, diagnostics);
    } else {
      return null;
    }
    if (uriSource == null) return _forbiddenImport(importerPath, diagnostics);
    final uri = Uri.tryParse(uriSource);
    if (uri == null || uri.hasQuery || uri.hasFragment) {
      return _forbiddenImport(importerPath, diagnostics);
    }
    if (uri.scheme == 'dart') {
      if (!allowedDartLibraries.contains(uriSource)) {
        _forbiddenImport(importerPath, diagnostics);
      }
      return null;
    }
    if (uri.scheme == 'package') {
      final prefix = 'package:$pluginId/';
      if (!uriSource.startsWith(prefix)) {
        return _forbiddenImport(importerPath, diagnostics);
      }
      final packagePath = uriSource.substring(prefix.length);
      if (!_validDartModulePath(packagePath)) {
        return _forbiddenImport(importerPath, diagnostics);
      }
      return packagePath;
    }
    if (uri.hasScheme || uri.hasAuthority || uriSource.startsWith('/')) {
      return _forbiddenImport(importerPath, diagnostics);
    }
    final resolved = p.posix.normalize(p.posix.join(p.posix.dirname(importerPath), uriSource));
    if (!_validDartModulePath(resolved)) {
      return _forbiddenImport(importerPath, diagnostics);
    }
    return resolved;
  }

  String? _forbiddenImport(
    String importerPath,
    List<PackageDiagnostic> diagnostics,
  ) {
    diagnostics.add(
      PackageDiagnostic.error(
        code: 'plugin.source.import_forbidden',
        message: 'Module contains an import or export outside the runtime allowlist.',
        relativePath: importerPath,
      ),
    );
    return null;
  }

  bool _validDartModulePath(String path) {
    return path.endsWith('.dart') && isPortablePluginPackagePath(path);
  }

  String _moduleId(String pluginId, String relativePath) => 'package:$pluginId/$relativePath';

  PackageDiagnostic _moduleReadDiagnostic(PluginPackageReadException error) {
    final (code, message) = switch (error.failure) {
      PluginPackageReadFailure.notFound => (
        'plugin.source.module_missing',
        'Imported Dart module does not exist.',
      ),
      PluginPackageReadFailure.notFile => (
        'plugin.source.module_not_file',
        'Imported Dart module must be a regular file.',
      ),
      PluginPackageReadFailure.tooLarge => (
        'plugin.source.module_too_large',
        'Dart module must not exceed $maxModuleBytes bytes.',
      ),
      PluginPackageReadFailure.symbolicLink => (
        'plugin.source.module_symbolic_link_forbidden',
        'Imported Dart module must not be a symbolic link.',
      ),
      PluginPackageReadFailure.changedDuringRead => (
        'plugin.source.module_changed_during_read',
        'Imported Dart module changed while it was being read.',
      ),
      PluginPackageReadFailure.pathCaseMismatch => (
        'plugin.source.module_path_case_mismatch',
        'Imported Dart module path must match exact on-disk casing.',
      ),
      PluginPackageReadFailure.invalidPath || PluginPackageReadFailure.outsidePackage => (
        'plugin.source.import_forbidden',
        'Imported Dart module must remain inside the plugin package.',
      ),
      PluginPackageReadFailure.io => (
        'plugin.source.module_unreadable',
        'Imported Dart module could not be read.',
      ),
    };
    return PackageDiagnostic.error(
      code: code,
      message: message,
      relativePath: error.relativePath,
    );
  }
}
