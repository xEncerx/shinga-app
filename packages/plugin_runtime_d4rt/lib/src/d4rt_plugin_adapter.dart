import 'dart:async';
import 'dart:collection';
import 'dart:convert';
import 'dart:isolate';
import 'dart:typed_data';

import 'package:analyzer/dart/analysis/features.dart';
import 'package:analyzer/dart/analysis/utilities.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/error/error.dart' as analyzer_error;
import 'package:d4rt/d4rt.dart';
import 'package:path/path.dart' as p;
import 'package:plugin_protocol/plugin_protocol.dart';
import 'package:plugin_runtime/plugin_runtime.dart';

const _executionObserverZoneKey = #pluginRuntimeD4rtExecutionObserver;

/// Validated cooperative controls applied by the D4rt adapter.
final class D4rtExecutionPolicy {
  /// Creates a policy within the D4rt adapter's release ceilings.
  factory D4rtExecutionPolicy({required int maxSteps, required Duration timeout}) {
    if (maxSteps <= 0 || maxSteps > maxAllowedSteps) {
      throw ArgumentError.value(maxSteps, 'maxSteps', 'must be within 1..10000000');
    }
    if (timeout <= Duration.zero || timeout > maxAllowedTimeout) {
      throw ArgumentError.value(timeout, 'timeout', 'must be within 1 microsecond and 30 seconds');
    }
    return D4rtExecutionPolicy._(maxSteps: maxSteps, timeout: timeout);
  }

  /// Creates the default bounded policy used by the D4rt adapter.
  const D4rtExecutionPolicy.defaults() : maxSteps = 100000, timeout = const Duration(seconds: 2);

  const D4rtExecutionPolicy._({required this.maxSteps, required this.timeout});

  /// Maximum supported cooperative interpreter step budget.
  static const int maxAllowedSteps = 10000000;

  /// Maximum supported cooperative interpreter timeout.
  static const Duration maxAllowedTimeout = Duration(seconds: 30);

  /// Maximum cooperative interpreter steps for one invocation.
  final int maxSteps;

  /// Cooperative timeout clamped to the shared absolute hard deadline.
  final Duration timeout;
}

/// Registers Dart source preflight and D4rt worker behavior with the runtime.
final class D4rtPluginAdapter implements PluginRuntimeAdapter {
  /// Creates an adapter with bounded source and cooperative execution policy.
  factory D4rtPluginAdapter({
    D4rtExecutionPolicy policy = const D4rtExecutionPolicy.defaults(),
    int maxModuleBytes = defaultMaxModuleBytes,
    int maxAggregateBytes = defaultMaxAggregateBytes,
  }) {
    if (maxModuleBytes <= 0 ||
        maxModuleBytes > defaultMaxModuleBytes ||
        maxAggregateBytes <= 0 ||
        maxAggregateBytes > defaultMaxAggregateBytes ||
        maxAggregateBytes < maxModuleBytes) {
      throw ArgumentError('Source limits must be positive and within D4rt ceilings.');
    }
    return D4rtPluginAdapter._(
      policy: policy,
      maxModuleBytes: maxModuleBytes,
      maxAggregateBytes: maxAggregateBytes,
    );
  }

  const D4rtPluginAdapter._({
    required this.policy,
    required this.maxModuleBytes,
    required this.maxAggregateBytes,
  });

  /// Maximum exact UTF-8 bytes in one Dart module.
  static const int defaultMaxModuleBytes = 256 * 1024;

  /// Maximum exact UTF-8 bytes across one Dart source graph.
  static const int defaultMaxAggregateBytes = 1024 * 1024;

  /// SDK libraries available to inspected Dart source.
  static const Set<String> allowedDartLibraries = {
    'dart:async',
    'dart:collection',
    'dart:convert',
    'dart:core',
    'dart:math',
  };

  /// D4rt cooperative controls bound into inspected artifacts.
  final D4rtExecutionPolicy policy;

  /// Maximum exact UTF-8 bytes in one Dart module.
  final int maxModuleBytes;

  /// Maximum exact UTF-8 bytes across one Dart source graph.
  final int maxAggregateBytes;

  @override
  String get id => 'd4rt';

  @override
  Set<String> get entryExtensions => const {'.dart'};

  @override
  Future<PluginArtifactBuildResult> inspect(
    PluginPackageReader package,
    PluginManifest manifest,
  ) {
    return _D4rtArtifactBuilder(
      maxModuleBytes: maxModuleBytes,
      maxAggregateBytes: maxAggregateBytes,
    ).build(package, manifest);
  }

  @override
  Object? createWorkerPayload(PluginExecutableArtifact artifact) {
    if (artifact.adapterId != id) {
      throw StateError('Artifact was not inspected by this adapter.');
    }
    final executionObserver = Zone.current[_executionObserverZoneKey];
    return <String, Object?>{
      'pluginId': artifact.pluginId,
      'entryPath': artifact.entryPath,
      'sourceBytes': artifact.copySourceBytes(),
      'maxSteps': policy.maxSteps,
      'timeoutMicroseconds': policy.timeout.inMicroseconds,
      if (executionObserver is SendPort) 'executionObserver': executionObserver,
    };
  }

  @override
  PluginWorkerEntrypoint get workerEntrypoint => _runD4rt;
}

final class _D4rtArtifactBuilder {
  const _D4rtArtifactBuilder({
    required this.maxModuleBytes,
    required this.maxAggregateBytes,
  });

  final int maxModuleBytes;
  final int maxAggregateBytes;

  Future<PluginArtifactBuildResult> build(
    PluginPackageReader package,
    PluginManifest manifest,
  ) async {
    final diagnostics = <PackageDiagnostic>[];
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
      if (await _aliasesLoadedModule(package, relativePath, loadedPaths, diagnostics)) continue;
      loadedPaths.add(relativePath);
      aggregateBytes += bytes.length;
      if (aggregateBytes > maxAggregateBytes) {
        diagnostics.add(
          PackageDiagnostic.error(
            code: 'plugin.source.aggregate_too_large',
            message: 'Dart source must not exceed $maxAggregateBytes aggregate bytes.',
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

      sourceBytes[relativePath] = bytes;
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
      return PluginArtifactBuildResult(diagnostics: diagnostics, candidate: null);
    }
    return PluginArtifactBuildResult(
      diagnostics: diagnostics,
      candidate: PluginArtifactCandidate(sourceBytes: sourceBytes),
    );
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
      if (!D4rtPluginAdapter.allowedDartLibraries.contains(uriSource)) {
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

  String? _forbiddenImport(String importerPath, List<PackageDiagnostic> diagnostics) {
    diagnostics.add(
      PackageDiagnostic.error(
        code: 'plugin.source.import_forbidden',
        message: 'Module contains an import or export outside the D4rt allowlist.',
        relativePath: importerPath,
      ),
    );
    return null;
  }

  bool _validDartModulePath(String path) {
    return path.endsWith('.dart') && isPortablePluginPackagePath(path);
  }

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

Future<PluginInvocationResponse> _runD4rt(
  PluginWorkerContext context,
  Object? adapterPayload,
) async {
  final payload = adapterPayload! as Map<Object?, Object?>;
  PluginInvocationResponse response;
  try {
    final d4rt = D4rt()
      ..registertopLevelFunction(
        '__shingaHostCall',
        (visitor, positionalArgs, namedArgs, typeArgs) {
          final operation = positionalArgs.firstOrNull;
          if (positionalArgs.length != 2 || operation is! String) {
            return Future<Map<String, Object?>>.value(
              context.hostCalls.encodeResponse(
                PluginHostCallResponse.failure(
                  callId: 'call-invalid',
                  error: PluginError(
                    category: PluginErrorCategory.protocolViolation,
                    code: 'host_call.arguments_invalid',
                  ),
                ),
              ),
            );
          }
          return context.hostCalls
              .call(operation, positionalArgs[1])
              .then(
                context.hostCalls.encodeResponse,
              );
        },
      );
    final pluginId = payload['pluginId']! as String;
    final sourceBytes = payload['sourceBytes']! as Map<Object?, Object?>;
    final sources = <String, String>{
      for (final entry in sourceBytes.entries)
        'package:$pluginId/${entry.key! as String}': utf8.decode(
          entry.value! as Uint8List,
          allowMalformed: false,
        ),
    };
    final configuredTimeoutMicroseconds = payload['timeoutMicroseconds']! as int;
    final remainingMicroseconds =
        context.deadlineEpochMicroseconds - DateTime.now().microsecondsSinceEpoch;
    final executionObserver = payload['executionObserver'];
    if (remainingMicroseconds <= 0) {
      if (executionObserver is SendPort) {
        executionObserver.send(<String, Object?>{
          'didExecute': false,
          'remainingMicroseconds': remainingMicroseconds,
        });
      }
      response = PluginInvocationResponse.failure(
        PluginError(category: PluginErrorCategory.timeout, code: 'invocation.hard_timeout'),
      );
    } else {
      final cooperativeTimeoutMicroseconds = configuredTimeoutMicroseconds < remainingMicroseconds
          ? configuredTimeoutMicroseconds
          : remainingMicroseconds;
      if (executionObserver is SendPort) {
        executionObserver.send(<String, Object?>{
          'didExecute': true,
          'remainingMicroseconds': remainingMicroseconds,
          'cooperativeTimeoutMicroseconds': cooperativeTimeoutMicroseconds,
        });
      }
      final result = await Future<Object?>.value(
        d4rt.execute(
              library: 'package:$pluginId/${payload['entryPath']! as String}',
              sources: sources,
              name: context.request.method,
              positionalArgs: [context.request.params],
              // Keep the security boundary explicit even though D4rt defaults to false.
              // ignore: avoid_redundant_argument_values
              allowFileSystemImports: false,
              maxSteps: payload['maxSteps']! as int,
              timeout: Duration(microseconds: cooperativeTimeoutMicroseconds),
              onPrint: (_) {},
            )
            as Object?,
      );
      response = PluginInvocationResponse.success(result);
    }
  } on ExecutionLimitException {
    response = PluginInvocationResponse.failure(
      PluginError(category: PluginErrorCategory.executionLimit, code: 'execution.step_limit'),
    );
  } on ExecutionTimeoutException {
    response = PluginInvocationResponse.failure(
      PluginError(category: PluginErrorCategory.timeout, code: 'execution.d4rt_timeout'),
    );
  } on PluginProtocolException {
    response = PluginInvocationResponse.failure(
      PluginError(category: PluginErrorCategory.protocolViolation, code: 'execution.value_invalid'),
    );
  } on SourceCodeException {
    response = PluginInvocationResponse.failure(
      PluginError(category: PluginErrorCategory.engineFailure, code: 'engine.source_failure'),
    );
  } on RuntimeError {
    response = PluginInvocationResponse.failure(
      PluginError(category: PluginErrorCategory.pluginException, code: 'plugin.exception'),
    );
  } on Object {
    response = PluginInvocationResponse.failure(
      PluginError(category: PluginErrorCategory.engineFailure, code: 'engine.failure'),
    );
  }
  return response;
}
