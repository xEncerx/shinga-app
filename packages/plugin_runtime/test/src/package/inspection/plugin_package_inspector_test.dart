import 'dart:async';
import 'dart:convert';
import 'dart:io';

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
      expect(valid.artifact.entryModuleId, 'package:dev.shinga.source/index.dart');
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

    for (final mutation in <({String path, String expectedCode})>[
      (path: 'index.dart', expectedCode: 'plugin.entry.changed_during_read'),
      (path: 'helper.dart', expectedCode: 'plugin.source.module_changed_during_read'),
    ]) {
      test('physical ${mutation.path} mutation cannot reach invocation construction', () async {
        final packageDirectory = await Directory.systemTemp.createTemp(
          'plugin_inspector_mutation_',
        );
        addTearDown(() async {
          if (packageDirectory.existsSync()) {
            await packageDirectory.delete(recursive: true);
          }
        });
        await File.fromUri(
          packageDirectory.uri.resolve(PluginPackageFormat.manifestPath),
        ).writeAsString(jsonEncode(_manifestJson()));
        await File.fromUri(packageDirectory.uri.resolve('index.dart')).writeAsString('''
import 'helper.dart';

Object? run(Object? value) => helper(value);
''');
        await File.fromUri(
          packageDirectory.uri.resolve('helper.dart'),
        ).writeAsString('Object? helper(Object? value) => value;');
        final reader = DirectoryPluginPackageReader(packageDirectory);
        var mutationCount = 0;

        final result = await runZoned(
          () => _inspector().inspect(reader),
          zoneValues: {
            #pluginRuntimeBeforeStableRead: (File activeFile) async {
              if (!activeFile.path.endsWith(mutation.path)) return;
              mutationCount += 1;
              await activeFile.writeAsString(
                '${await activeFile.readAsString()}\n',
                flush: true,
              );
              await activeFile.setLastModified(
                DateTime.now().add(const Duration(seconds: 2)),
              );
            },
          },
        );
        var invocationConstructionCount = 0;
        if (result is ValidPluginPackage) {
          invocationConstructionCount += 1;
        }

        expect(mutationCount, 1);
        expect(result, isA<InvalidPluginPackage>());
        expect(
          result.diagnostics,
          contains(
            isA<PackageDiagnostic>()
                .having((diagnostic) => diagnostic.code, 'code', mutation.expectedCode)
                .having((diagnostic) => diagnostic.relativePath, 'relativePath', mutation.path),
          ),
        );
        expect(invocationConstructionCount, 0);
      });
    }
  });
}

PluginPackageInspector _inspector() {
  final parser = PluginManifestParser();
  return PluginPackageInspector(
    manifestLoader: PluginManifestLoader(parser: parser),
    packageValidator: const PluginPackageValidator(),
    compatibilityPolicy: PluginCompatibilityPolicy(
      parser: parser,
      supportedPluginApiVersions: supportedPluginApiVersions,
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
      if (includeEntry) 'index.dart': utf8.encode('Object? echo(Object? value) => value;'),
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
    'entry': 'index.dart',
  };
}
