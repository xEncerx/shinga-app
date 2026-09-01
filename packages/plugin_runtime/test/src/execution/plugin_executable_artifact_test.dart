import 'dart:typed_data';

import 'package:plugin_protocol/plugin_protocol.dart';
import 'package:plugin_runtime/plugin_runtime.dart';
import 'package:plugin_runtime/plugin_runtime_testing.dart';
import 'package:test/test.dart';

void main() {
  group('PluginExecutableArtifact', () {
    test('shared validation binds identity and exact defensive source bytes', () async {
      final bytes = Uint8List.fromList([1, 2, 3]);
      final sourceBytes = <String, Uint8List>{'index.dart': bytes};
      final candidate = PluginArtifactCandidate(sourceBytes: sourceBytes);
      final adapter = _FakeAdapter('fixture', {'.dart'}, candidate: candidate);

      bytes[0] = 9;
      sourceBytes['late.dart'] = Uint8List.fromList([4]);
      final result = await const PluginPackageValidator().validate(
        MemoryPluginPackageReader(
          files: {
            'index.dart': const [32],
          },
        ),
        _manifest('index.dart'),
        adapter,
      );
      candidate.copySourceBytes()['index.dart']![1] = 8;

      final artifact = result.artifact!;
      expect(artifact.pluginId, 'dev.shinga.fixture');
      expect(artifact.pluginVersion, '1.0.0');
      expect(artifact.pluginApiVersion, 1);
      expect(artifact.entryPath, 'index.dart');
      expect(artifact.adapterId, 'fixture');
      expect(artifact.copySourceBytes(), {
        'index.dart': [1, 2, 3],
      });
      artifact.copySourceBytes()['index.dart']![2] = 7;
      expect(artifact.copySourceBytes()['index.dart'], [1, 2, 3]);
    });

    test('candidate cannot be used as an executable artifact', () {
      final candidate = PluginArtifactCandidate(
        sourceBytes: {
          'index.dart': Uint8List.fromList([1]),
        },
      );

      expect(candidate, isNot(isA<PluginExecutableArtifact>()));
    });
  });

  group('PluginRuntimeAdapterRegistry', () {
    test('dispatches exact case-sensitive entry extensions', () {
      final dart = _FakeAdapter('dart', {'.dart'});
      final javaScript = _FakeAdapter('javascript', {'.js'});
      final registry = PluginRuntimeAdapterRegistry([dart, javaScript]);

      expect(registry.adapterForEntry(PluginEntryPath.tryParse('src/main.dart')!), same(dart));
      expect(
        registry.adapterForEntry(PluginEntryPath.tryParse('src/main.js')!),
        same(javaScript),
      );
      expect(registry.adapterForEntry(PluginEntryPath.tryParse('src/main.DART')!), isNull);
      expect(registry.adapterForEntry(PluginEntryPath.tryParse('src/main')!), isNull);
      expect(registry.adapterById('dart'), same(dart));
    });

    test('rejects duplicate adapter ids and extensions', () {
      expect(
        () => PluginRuntimeAdapterRegistry([
          _FakeAdapter('same', {'.dart'}),
          _FakeAdapter('same', {'.js'}),
        ]),
        throwsArgumentError,
      );
      expect(
        () => PluginRuntimeAdapterRegistry([
          _FakeAdapter('dart-a', {'.dart'}),
          _FakeAdapter('dart-b', {'.dart'}),
        ]),
        throwsArgumentError,
      );
    });
  });
}

PluginManifest _manifest(String entry) => PluginManifest(
  manifestVersion: ManifestFormatVersion.tryParse(1)!,
  id: PluginId.tryParse('dev.shinga.fixture')!,
  name: 'Fixture',
  version: PluginVersion.tryParse('1.0.0')!,
  pluginApiVersion: PluginApiVersion.tryParse(1)!,
  entry: PluginEntryPath.tryParse(entry)!,
  permissions: const PluginPermissions(),
  settings: const [],
);

final class _FakeAdapter implements PluginRuntimeAdapter {
  _FakeAdapter(this.id, this.entryExtensions, {this.candidate});

  @override
  final String id;

  @override
  final Set<String> entryExtensions;

  final PluginArtifactCandidate? candidate;

  @override
  Object? createWorkerPayload(PluginExecutableArtifact artifact) => null;

  @override
  Future<PluginArtifactBuildResult> inspect(
    PluginPackageReader package,
    PluginManifest manifest,
  ) async {
    return PluginArtifactBuildResult(diagnostics: const [], candidate: candidate);
  }

  @override
  PluginWorkerEntrypoint get workerEntrypoint => _unusedWorker;
}

PluginInvocationResponseV1 _unusedWorker(PluginWorkerContext context, Object? payload) {
  return PluginInvocationResponseV1.success(null);
}
