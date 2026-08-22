import 'dart:convert';

import 'package:plugin_protocol/plugin_protocol.dart';
import 'package:plugin_runtime/src/package/loading/manifest_load_result.dart';
import 'package:plugin_runtime/src/package/reader/reader.dart';

/// Loads and parses the manifest stored in a plugin package.
final class PluginManifestLoader {
  /// Creates a loader using [parser] and a bounded manifest size.
  const PluginManifestLoader({
    required this.parser,
    this.maxManifestBytes = defaultMaxManifestBytes,
  }) : assert(maxManifestBytes >= 0, 'maxManifestBytes must not be negative.');

  /// The default maximum manifest size of 256 KiB.
  static const int defaultMaxManifestBytes = 256 * 1024;

  /// The parser used after strict UTF-8 decoding.
  final PluginManifestParser parser;

  /// The maximum accepted manifest size in bytes.
  final int maxManifestBytes;

  /// Loads, decodes, and parses `manifest.json` from [package].
  Future<ManifestLoadResult> load(PluginPackageReader package) async {
    final diagnostics = <PluginDiagnostic>[];
    final PluginPackageEntry? entry;
    try {
      entry = await package.stat(PluginPackageFormat.manifestPath);
    } on PluginPackageReadException catch (error) {
      diagnostics.add(_readFailureDiagnostic(error));
      return ManifestLoadResult(manifest: null, diagnostics: diagnostics);
    }

    if (entry == null) {
      diagnostics.add(
        _error(
          code: 'plugin.package.manifest_missing',
          message: 'Plugin package does not contain manifest.json.',
        ),
      );
      return ManifestLoadResult(manifest: null, diagnostics: diagnostics);
    }
    if (entry.type != PluginPackageEntryType.file) {
      diagnostics.add(
        _error(
          code: entry.type == PluginPackageEntryType.symbolicLink
              ? 'plugin.package.manifest_symbolic_link_forbidden'
              : 'plugin.package.manifest_not_file',
          message: entry.type == PluginPackageEntryType.symbolicLink
              ? 'manifest.json must not be a symbolic link.'
              : 'manifest.json must be a regular file.',
        ),
      );
      return ManifestLoadResult(manifest: null, diagnostics: diagnostics);
    }
    if (entry.size > maxManifestBytes) {
      diagnostics.add(_manifestTooLarge());
      return ManifestLoadResult(manifest: null, diagnostics: diagnostics);
    }

    final List<int> bytes;
    try {
      bytes = await package.readBytes(
        PluginPackageFormat.manifestPath,
        maxBytes: maxManifestBytes,
      );
    } on PluginPackageReadException catch (error) {
      diagnostics.add(_readFailureDiagnostic(error));
      return ManifestLoadResult(manifest: null, diagnostics: diagnostics);
    }

    final String source;
    try {
      final decoded = utf8.decode(bytes, allowMalformed: false);
      source = decoded.startsWith('\uFEFF') ? decoded.substring(1) : decoded;
    } on FormatException {
      diagnostics.add(
        _error(
          code: 'plugin.package.manifest_invalid_utf8',
          message: 'manifest.json must contain valid UTF-8 text.',
        ),
      );
      return ManifestLoadResult(manifest: null, diagnostics: diagnostics);
    }

    final parsed = parser.parse(source);
    diagnostics.addAll(parsed.diagnostics);
    return ManifestLoadResult(
      manifest: parsed.manifest,
      diagnostics: diagnostics,
    );
  }

  PackageDiagnostic _readFailureDiagnostic(PluginPackageReadException error) {
    return switch (error.failure) {
      PluginPackageReadFailure.notFound => _error(
        code: 'plugin.package.manifest_missing',
        message: 'Plugin package does not contain manifest.json.',
      ),
      PluginPackageReadFailure.tooLarge => _manifestTooLarge(),
      PluginPackageReadFailure.notFile => _error(
        code: 'plugin.package.manifest_not_file',
        message: 'manifest.json must be a regular file.',
      ),
      PluginPackageReadFailure.symbolicLink => _error(
        code: 'plugin.package.manifest_symbolic_link_forbidden',
        message: 'manifest.json must not be a symbolic link.',
      ),
      PluginPackageReadFailure.invalidPath ||
      PluginPackageReadFailure.outsidePackage ||
      PluginPackageReadFailure.io => _error(
        code: 'plugin.package.manifest_unreadable',
        message: 'manifest.json could not be read.',
      ),
    };
  }

  PackageDiagnostic _manifestTooLarge() {
    return _error(
      code: 'plugin.package.manifest_too_large',
      message: 'manifest.json must not exceed $maxManifestBytes bytes.',
    );
  }

  PackageDiagnostic _error({required DiagnosticCode code, required String message}) {
    return PackageDiagnostic.error(
      code: code,
      message: message,
      relativePath: PluginPackageFormat.manifestPath,
    );
  }
}
