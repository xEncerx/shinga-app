import 'dart:convert';

import 'package:plugin_protocol/src/common/common.dart';
import 'package:plugin_protocol/src/manifest/models/models.dart';
import 'package:plugin_protocol/src/manifest/parsing/manifest_v1_decoder.dart';
import 'package:plugin_protocol/src/manifest/parsing/plugin_manifest_parser.dart';

/// The default JSON-based implementation of [PluginManifestParser].
final class PluginManifestParserImpl implements PluginManifestParser {
  /// Creates the default parser implementation.
  const PluginManifestParserImpl();

  @override
  Set<int> get supportedManifestVersions => const {1};

  @override
  ManifestParseResult parse(String source) {
    final diagnostics = DiagnosticCollector();
    final Object? decoded;
    try {
      decoded = jsonDecode(source);
    } on FormatException {
      diagnostics.error(
        code: 'manifest.json.invalid',
        path: const JsonPath.root(),
        message: 'Invalid JSON.',
      );
      return _result(null, diagnostics);
    }

    if (decoded is! JsonObject) {
      diagnostics.reportTypeMismatch(
        path: const JsonPath.root(),
        expected: 'object',
        actual: decoded,
      );
      return _result(null, diagnostics);
    }

    final reader = JsonObjectReader(
      value: decoded,
      path: const JsonPath.root(),
      diagnostics: diagnostics,
    );
    final rawManifestVersion = reader.requiredInt('manifestVersion');
    if (rawManifestVersion == null) {
      return _result(null, diagnostics);
    }

    final manifestVersion = ManifestFormatVersion.tryParse(rawManifestVersion);
    if (manifestVersion == null) {
      diagnostics.error(
        code: 'manifest.version.invalid',
        path: const JsonPath.root().field('manifestVersion'),
        message: 'Manifest version must be a positive integer.',
      );
      return _result(null, diagnostics);
    }

    final PluginManifest? manifest;
    switch (manifestVersion.value) {
      case 1:
        manifest = decodeManifestV1(reader, diagnostics);
      default:
        diagnostics.error(
          code: 'manifest.version.unsupported',
          path: const JsonPath.root().field('manifestVersion'),
          message: 'Unsupported manifest version ${manifestVersion.value}.',
        );
        manifest = null;
    }
    return _result(diagnostics.hasErrors ? null : manifest, diagnostics);
  }

  ManifestParseResult _result(
    PluginManifest? manifest,
    DiagnosticCollector diagnostics,
  ) {
    return ManifestParseResult(
      manifest: manifest,
      diagnostics: diagnostics.diagnostics,
    );
  }
}
