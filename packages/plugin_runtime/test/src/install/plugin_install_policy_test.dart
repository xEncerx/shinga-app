import 'dart:convert';
import 'dart:typed_data';

import 'package:plugin_protocol/plugin_protocol.dart';
import 'package:plugin_runtime/plugin_runtime.dart';
import 'package:plugin_runtime/plugin_runtime_testing.dart';
import 'package:test/test.dart';

void main() {
  group('PluginInstallPolicy', () {
    test('allows a fresh installation', () async {
      final policy = _policy(registry: const _FakeInstalledPluginRegistry());

      final result = await policy.validate(await _package(version: '1.0.0'));

      expect(result.isAllowed, isTrue);
      expect(result.operation, PluginInstallOperation.install);
      expect(result.diagnostics, isEmpty);
      expect(result.requiresPermissionApproval, isFalse);
    });

    test('allows an update with higher SemVer precedence', () async {
      final installed = _record(version: '1.0.0');
      final policy = _policy(registry: _FakeInstalledPluginRegistry(installed));

      final result = await policy.validate(await _package(version: '1.1.0'));

      expect(result.isAllowed, isTrue);
      expect(result.operation, PluginInstallOperation.update);
      expect(result.diagnostics, isEmpty);
    });

    test('rejects an exactly duplicate version', () async {
      final installed = _record(version: '1.0.0');
      final policy = _policy(registry: _FakeInstalledPluginRegistry(installed));

      final result = await policy.validate(await _package(version: '1.0.0'));

      expect(result.isAllowed, isFalse);
      expect(result.operation, isNull);
      expect(result.diagnostics.single.code, 'plugin.install.duplicate');
    });

    test('rejects a downgrade', () async {
      final installed = _record(version: '2.0.0');
      final policy = _policy(registry: _FakeInstalledPluginRegistry(installed));

      final result = await policy.validate(await _package(version: '1.9.9'));

      expect(result.isAllowed, isFalse);
      expect(result.diagnostics.single.code, 'plugin.install.downgrade_forbidden');
    });

    test('rejects build-only changes with equal SemVer precedence', () async {
      final installed = _record(version: '1.0.0+build.1');
      final policy = _policy(registry: _FakeInstalledPluginRegistry(installed));

      final result = await policy.validate(await _package(version: '1.0.0+build.2'));

      expect(result.isAllowed, isFalse);
      expect(result.diagnostics.single.code, 'plugin.install.version_not_newer');
    });

    test('rejects a permission unsupported by the host', () async {
      final policy = _policy(
        registry: const _FakeInstalledPluginRegistry(),
        allowNetworkPermission: false,
      );
      final permissions = _permissions(['api.example.com']);

      final result = await policy.validate(
        await _package(version: '1.0.0', permissions: permissions),
      );

      expect(result.isAllowed, isFalse);
      expect(result.operation, isNull);
      expect(result.diagnostics.single.code, 'plugin.install.permission_unsupported');
      expect(result.requiresPermissionApproval, isTrue);
      expect(result.addedNetworkHosts.map((host) => host.toString()), ['api.example.com']);
    });

    test('reports only network hosts added by an update', () async {
      final installed = _record(
        version: '1.0.0',
        permissions: _permissions(['*.example.com', 'static.example.net']),
      );
      final policy = _policy(registry: _FakeInstalledPluginRegistry(installed));
      final requested = _permissions([
        'api.example.com',
        '*.example.com',
        'static.example.net',
        'new.example.org',
      ]);

      final result = await policy.validate(
        await _package(version: '1.1.0', permissions: requested),
      );

      expect(result.isAllowed, isTrue);
      expect(result.operation, PluginInstallOperation.update);
      expect(result.requiresPermissionApproval, isTrue);
      expect(result.addedNetworkHosts.map((host) => host.toString()), ['new.example.org']);
    });

    test('accepts the result of the complete package inspection pipeline', () async {
      final parser = PluginManifestParser();
      final inspector = PluginPackageInspector(
        manifestLoader: PluginManifestLoader(parser: parser),
        packageValidator: const PluginPackageValidator(),
        compatibilityPolicy: PluginCompatibilityPolicy(
          parser: parser,
          supportedPluginApiVersions: supportedPluginApiVersions,
        ),
        adapterRegistry: PluginRuntimeAdapterRegistry([const _InstallFixtureAdapter()]),
      );
      final reader = MemoryPluginPackageReader(
        files: {
          PluginPackageFormat.manifestPath: utf8.encode(
            '{"manifestVersion":1,"id":"dev.shinga.source","name":"Source",'
            '"version":"1.0.0","pluginApiVersion":1,"entry":"index.dart"}',
          ),
          'index.dart': const [32],
        },
      );
      final inspection = await inspector.inspect(reader);
      final policy = _policy(registry: const _FakeInstalledPluginRegistry());

      final result = await policy.validate(inspection as ValidPluginPackage);

      expect(result.isAllowed, isTrue);
      expect(result.operation, PluginInstallOperation.install);
    });
  });
}

PluginInstallPolicy _policy({
  required InstalledPluginRegistry registry,
  bool allowNetworkPermission = true,
}) {
  return PluginInstallPolicy(
    registry: registry,
    compatibility: PluginCompatibilityPolicy(
      parser: PluginManifestParser(),
      supportedPluginApiVersions: supportedPluginApiVersions,
    ),
    allowNetworkPermission: allowNetworkPermission,
  );
}

Future<ValidPluginPackage> _package({
  required String version,
  PluginPermissions permissions = const PluginPermissions(),
}) async {
  final parser = PluginManifestParser();
  final inspector = PluginPackageInspector(
    manifestLoader: PluginManifestLoader(parser: parser),
    packageValidator: const PluginPackageValidator(),
    compatibilityPolicy: PluginCompatibilityPolicy(
      parser: parser,
      supportedPluginApiVersions: supportedPluginApiVersions,
    ),
    adapterRegistry: PluginRuntimeAdapterRegistry([const _InstallFixtureAdapter()]),
  );
  final network = permissions.network;
  final reader = MemoryPluginPackageReader(
    files: {
      PluginPackageFormat.manifestPath: utf8.encode(
        jsonEncode({
          'manifestVersion': 1,
          'id': 'dev.shinga.source',
          'name': 'Source',
          'version': version,
          'pluginApiVersion': 1,
          'entry': 'index.dart',
          if (network != null)
            'permissions': {
              'network': {
                'hosts': network.hosts.map((host) => host.toString()).toList(),
              },
            },
        }),
      ),
      'index.dart': const [32],
    },
  );
  return await inspector.inspect(reader) as ValidPluginPackage;
}

final class _InstallFixtureAdapter implements PluginRuntimeAdapter {
  const _InstallFixtureAdapter();

  @override
  String get id => 'fixture';

  @override
  Set<String> get entryExtensions => const {'.dart'};

  @override
  Object? createWorkerPayload(PluginExecutableArtifact artifact) => null;

  @override
  Future<PluginArtifactBuildResult> inspect(
    PluginPackageReader package,
    PluginManifest manifest,
  ) async {
    final bytes = Uint8List.fromList(
      await package.readBytes(manifest.entry.value, maxBytes: 256 * 1024),
    );
    return PluginArtifactBuildResult(
      diagnostics: const [],
      candidate: PluginArtifactCandidate(
        sourceBytes: {manifest.entry.value: bytes},
      ),
    );
  }

  @override
  PluginWorkerEntrypoint get workerEntrypoint => _installFixtureWorker;
}

PluginInvocationResponseV1 _installFixtureWorker(
  PluginWorkerContext context,
  Object? payload,
) {
  return PluginInvocationResponseV1.success(null);
}

InstalledPluginRecord _record({
  required String version,
  PluginPermissions permissions = const PluginPermissions(),
}) {
  return InstalledPluginRecord(
    id: PluginId.tryParse('dev.shinga.source')!,
    version: PluginVersion.tryParse(version)!,
    permissions: permissions,
  );
}

PluginPermissions _permissions(List<String> hosts) {
  return PluginPermissions(
    network: NetworkPermission(
      hosts: hosts.map((host) => NetworkHostPattern.tryParse(host)!).toList(),
    ),
  );
}

final class _FakeInstalledPluginRegistry implements InstalledPluginRegistry {
  const _FakeInstalledPluginRegistry([this.record]);

  final InstalledPluginRecord? record;

  @override
  Future<InstalledPluginRecord?> find(PluginId id) async {
    return record?.id == id ? record : null;
  }
}
