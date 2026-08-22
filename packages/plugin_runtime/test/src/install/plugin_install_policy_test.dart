import 'package:plugin_protocol/plugin_protocol.dart';
import 'package:plugin_runtime/plugin_runtime.dart';
import 'package:test/test.dart';

void main() {
  group('PluginInstallPolicy', () {
    test('allows a fresh installation', () async {
      final policy = _policy(registry: const _FakeInstalledPluginRegistry());

      final result = await policy.validate(_manifest(version: '1.0.0'));

      expect(result.isAllowed, isTrue);
      expect(result.operation, PluginInstallOperation.install);
      expect(result.diagnostics, isEmpty);
      expect(result.requiresPermissionApproval, isFalse);
    });

    test('allows an update with higher SemVer precedence', () async {
      final installed = _record(version: '1.0.0');
      final policy = _policy(registry: _FakeInstalledPluginRegistry(installed));

      final result = await policy.validate(_manifest(version: '1.1.0'));

      expect(result.isAllowed, isTrue);
      expect(result.operation, PluginInstallOperation.update);
      expect(result.diagnostics, isEmpty);
    });

    test('rejects an exactly duplicate version', () async {
      final installed = _record(version: '1.0.0');
      final policy = _policy(registry: _FakeInstalledPluginRegistry(installed));

      final result = await policy.validate(_manifest(version: '1.0.0'));

      expect(result.isAllowed, isFalse);
      expect(result.operation, isNull);
      expect(result.diagnostics.single.code, 'plugin.install.duplicate');
    });

    test('rejects a downgrade', () async {
      final installed = _record(version: '2.0.0');
      final policy = _policy(registry: _FakeInstalledPluginRegistry(installed));

      final result = await policy.validate(_manifest(version: '1.9.9'));

      expect(result.isAllowed, isFalse);
      expect(result.diagnostics.single.code, 'plugin.install.downgrade_forbidden');
    });

    test('rejects build-only changes with equal SemVer precedence', () async {
      final installed = _record(version: '1.0.0+build.1');
      final policy = _policy(registry: _FakeInstalledPluginRegistry(installed));

      final result = await policy.validate(_manifest(version: '1.0.0+build.2'));

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
        _manifest(version: '1.0.0', permissions: permissions),
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
        _manifest(version: '1.1.0', permissions: requested),
      );

      expect(result.isAllowed, isTrue);
      expect(result.operation, PluginInstallOperation.update);
      expect(result.requiresPermissionApproval, isTrue);
      expect(result.addedNetworkHosts.map((host) => host.toString()), ['new.example.org']);
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
      supportedPluginApiVersions: const {1},
    ),
    allowNetworkPermission: allowNetworkPermission,
  );
}

PluginManifest _manifest({
  required String version,
  PluginPermissions permissions = const PluginPermissions(),
}) {
  return PluginManifest(
    manifestVersion: ManifestFormatVersion.tryParse(1)!,
    id: PluginId.tryParse('dev.shinga.source')!,
    name: 'Source',
    version: PluginVersion.tryParse(version)!,
    pluginApiVersion: PluginApiVersion.tryParse(1)!,
    entry: PluginEntryPath.tryParse('index.js')!,
    permissions: permissions,
    settings: const [],
  );
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
