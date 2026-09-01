import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

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
      expect(valid.artifact.adapterId, 'fixture');
      expect(valid.artifact.wireProtocolVersion, 1);
      expect(valid.artifact.copySourceBytes()['index.dart'], isNotEmpty);
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

    test('rejects unsupported API before language adapter inspection', () async {
      var inspectCount = 0;
      final inspector = _inspector(
        adapter: _FixtureAdapter(onInspect: () => inspectCount += 1),
      );
      final package = _package(
        _manifestJson(pluginApiVersion: 99),
        includeEntry: true,
      );

      final result = await inspector.inspect(package);

      expect(result, isA<InvalidPluginPackage>());
      expect(
        result.diagnostics.map((diagnostic) => diagnostic.code),
        ['plugin.compatibility.api_version_unsupported'],
      );
      expect(inspectCount, 0);
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

    test('binds API2 to wire v1 while API1 remains registered', () async {
      final result = await _inspector(
        includeApi2: true,
      ).inspect(_package(_manifestJson(pluginApiVersion: 2), includeEntry: true));

      expect(result, isA<ValidPluginPackage>());
      final artifact = (result as ValidPluginPackage).artifact;
      expect(artifact.pluginApiVersion, 2);
      expect(artifact.wireProtocolVersion, 1);
    });

    test('physical entry mutation cannot reach invocation construction', () async {
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
            if (!activeFile.path.endsWith('index.dart')) return;
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
              .having(
                (diagnostic) => diagnostic.code,
                'code',
                'plugin.entry.changed_during_read',
              )
              .having(
                (diagnostic) => diagnostic.relativePath,
                'relativePath',
                'index.dart',
              ),
        ),
      );
      expect(invocationConstructionCount, 0);
    });

    test('rejects unsupported and case-mismatched extensions before source reads', () async {
      for (final entry in ['index.js', 'index.DART']) {
        final result = await _inspector().inspect(
          _package({..._manifestJson(), 'entry': entry}, includeEntry: false),
        );

        expect(result, isA<InvalidPluginPackage>());
        expect(result.diagnostics.single.code, 'plugin.entry.adapter_unsupported');
        expect(
          result.diagnostics.single.message,
          contains(entry.substring(entry.lastIndexOf('.'))),
        );
      }
    });

    test('rejects adapter output without diagnostics or a candidate', () async {
      final result = await _inspector(
        adapter: _FixtureAdapter(
          artifactBuilder: (_) => PluginArtifactBuildResult(
            diagnostics: const [],
            candidate: null,
          ),
        ),
      ).inspect(_package(_manifestJson(), includeEntry: true));

      _expectInvalidAdapterOutput(result);
    });

    test('converts missing entry source output to a safe diagnostic', () async {
      final result = await _inspector(
        adapter: _FixtureAdapter(
          artifactBuilder: (manifest) => PluginArtifactBuildResult(
            diagnostics: const [],
            candidate: PluginArtifactCandidate(
              sourceBytes: {
                'other.dart': Uint8List.fromList([1]),
              },
            ),
          ),
        ),
      ).inspect(_package(_manifestJson(), includeEntry: true));

      _expectInvalidAdapterOutput(result);
    });
  });
}

PluginPackageInspector _inspector({
  PluginRuntimeAdapter adapter = const _FixtureAdapter(),
  bool includeApi2 = false,
}) {
  final parser = PluginManifestParser();
  final wireProtocols = PluginWireProtocolRegistry.builtIn();
  return PluginPackageInspector(
    manifestLoader: PluginManifestLoader(parser: parser),
    packageValidator: const PluginPackageValidator(),
    compatibilityPolicy: PluginCompatibilityPolicy(
      parser: parser,
      apiRegistry: PluginApiRegistry(
        adapters: [
          const PluginApiV1Adapter(),
          if (includeApi2) const _InspectorApi2Adapter(),
        ],
        wireProtocols: wireProtocols,
      ),
    ),
    adapterRegistry: PluginRuntimeAdapterRegistry([adapter]),
  );
}

final class _InspectorApi2Adapter implements PluginApiAdapter {
  const _InspectorApi2Adapter();

  @override
  int get pluginApiVersion => 2;

  @override
  int get wireProtocolVersion => 1;
}

final class _FixtureAdapter implements PluginRuntimeAdapter {
  const _FixtureAdapter({this.artifactBuilder, this.onInspect});

  @override
  String get id => 'fixture';

  @override
  Set<String> get entryExtensions => const {'.dart'};

  final PluginArtifactBuildResult Function(PluginManifest manifest)? artifactBuilder;
  final void Function()? onInspect;

  @override
  Object? createWorkerPayload(PluginExecutableArtifact artifact) => artifact.copySourceBytes();

  @override
  Future<PluginArtifactBuildResult> inspect(
    PluginPackageReader package,
    PluginManifest manifest,
  ) async {
    onInspect?.call();
    if (artifactBuilder case final artifactBuilder?) {
      return artifactBuilder(manifest);
    }
    try {
      final bytes = Uint8List.fromList(
        await package.readBytes(manifest.entry.value, maxBytes: 256 * 1024),
      );
      return PluginArtifactBuildResult(
        diagnostics: const [],
        candidate: PluginArtifactCandidate(
          sourceBytes: {manifest.entry.value: bytes},
        ),
      );
    } on PluginPackageReadException catch (error) {
      return PluginArtifactBuildResult(
        diagnostics: [
          PackageDiagnostic.error(
            code: switch (error.failure) {
              PluginPackageReadFailure.changedDuringRead =>
                'plugin.source.module_changed_during_read',
              _ => 'plugin.source.module_unreadable',
            },
            message: 'Fixture source could not be read.',
            relativePath: error.relativePath,
          ),
        ],
        candidate: null,
      );
    }
  }

  @override
  PluginWorkerEntrypoint get workerEntrypoint => _fixtureWorker;
}

void _expectInvalidAdapterOutput(PluginPackageInspection result) {
  expect(result, isA<InvalidPluginPackage>());
  expect(result.diagnostics, [
    isA<PackageDiagnostic>()
        .having(
          (diagnostic) => diagnostic.code,
          'code',
          'plugin.entry.adapter_output_invalid',
        )
        .having(
          (diagnostic) => diagnostic.message,
          'message',
          'Runtime adapter produced invalid inspection output.',
        )
        .having(
          (diagnostic) => diagnostic.relativePath,
          'relativePath',
          'index.dart',
        )
        .having(
          (diagnostic) => diagnostic.manifestPath.toString(),
          'manifestPath',
          r'$.entry',
        ),
  ]);
}

PluginInvocationResponse _fixtureWorker(PluginWorkerContext context, Object? payload) {
  return PluginInvocationResponse.success(null);
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
