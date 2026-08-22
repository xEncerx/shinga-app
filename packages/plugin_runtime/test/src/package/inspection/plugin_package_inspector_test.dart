import 'dart:convert';

import 'package:plugin_protocol/plugin_protocol.dart';
import 'package:plugin_runtime/plugin_runtime.dart';
import 'package:plugin_runtime/plugin_runtime_testing.dart';
import 'package:test/test.dart';

void main() {
  group('PluginPackageInspector', () {
    test('returns a valid package for a complete compatible package', () async {
      final inspector = _inspector();
      final package = _package(_manifestJson(), includeEntry: true);

      final result = await inspector.inspect(package);

      expect(result, isA<ValidPluginPackage>());
      final valid = result as ValidPluginPackage;
      expect(valid.manifest.id.value, 'dev.shinga.source');
      expect(valid.diagnostics, isEmpty);
    });

    test('returns parser-invalid package without running later stages', () async {
      final inspector = _inspector();
      final package = MemoryPluginPackageReader(
        files: {
          PluginPackageFormat.manifestPath: utf8.encode('{"manifestVersion": 1'),
        },
      );

      final result = await inspector.inspect(package);

      expect(result, isA<InvalidPluginPackage>());
      expect(result.diagnostics.single.code, 'manifest.json.invalid');
    });

    test('aggregates package validation and compatibility errors', () async {
      final inspector = _inspector();
      final package = _package(
        _manifestJson(pluginApiVersion: 99),
        includeEntry: false,
      );

      final result = await inspector.inspect(package);

      expect(result, isA<InvalidPluginPackage>());
      expect(
        result.diagnostics.map((diagnostic) => diagnostic.code),
        [
          'plugin.entry.missing',
          'plugin.compatibility.api_version_unsupported',
        ],
      );
    });

    test('preserves loader warnings on an otherwise valid package', () async {
      final inspector = _inspector();
      final package = _package(
        {..._manifestJson(), 'futureField': true},
        includeEntry: true,
      );

      final result = await inspector.inspect(package);

      expect(result, isA<ValidPluginPackage>());
      expect(result.diagnostics.single.code, 'manifest.field.unknown');
      expect(result.diagnostics.single.severity, DiagnosticSeverity.warning);
    });
  });
}

PluginPackageInspector _inspector() {
  final parser = PluginManifestParser();
  return PluginPackageInspector(
    manifestLoader: PluginManifestLoader(parser: parser),
    packageValidator: const PluginPackageValidator(),
    compatibilityPolicy: PluginCompatibilityPolicy(
      parser: parser,
      supportedPluginApiVersions: const {1},
    ),
  );
}

MemoryPluginPackageReader _package(
  Map<String, Object?> manifest, {
  required bool includeEntry,
}) {
  return MemoryPluginPackageReader(
    files: {
      PluginPackageFormat.manifestPath: utf8.encode(jsonEncode(manifest)),
      if (includeEntry) 'index.js': const [0],
    },
  );
}

Map<String, Object?> _manifestJson({int pluginApiVersion = 1}) {
  return <String, Object?>{
    'manifestVersion': 1,
    'id': 'dev.shinga.source',
    'name': 'Source',
    'version': '1.0.0',
    'pluginApiVersion': pluginApiVersion,
    'entry': 'index.js',
  };
}
