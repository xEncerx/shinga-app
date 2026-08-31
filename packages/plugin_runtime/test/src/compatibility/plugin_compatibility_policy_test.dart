import 'package:plugin_protocol/plugin_protocol.dart';
import 'package:plugin_runtime/plugin_runtime.dart';
import 'package:test/test.dart';

void main() {
  group('PluginCompatibilityPolicy', () {
    test('accepts supported manifest and Plugin API versions', () {
      final policy = PluginCompatibilityPolicy(
        parser: PluginManifestParser(),
        supportedPluginApiVersions: supportedPluginApiVersions,
      );

      final result = policy.validate(_manifest());

      expect(result.isCompatible, isTrue);
      expect(result.diagnostics, isEmpty);
    });

    test('declares the Plugin API versions implemented by this runtime', () {
      expect(supportedPluginApiVersions, {1});
      expect(() => supportedPluginApiVersions.add(2), throwsUnsupportedError);
    });

    test('reports unsupported manifest and Plugin API versions independently', () {
      final policy = PluginCompatibilityPolicy(
        parser: PluginManifestParser(),
        supportedPluginApiVersions: {1},
      );
      final manifest = _manifest(manifestVersion: 2, pluginApiVersion: 99);

      final result = policy.validate(manifest);

      expect(result.isCompatible, isFalse);
      expect(
        result.diagnostics.map((diagnostic) => diagnostic.code),
        [
          'plugin.compatibility.manifest_version_unsupported',
          'plugin.compatibility.api_version_unsupported',
        ],
      );
      expect(
        result.diagnostics.map((diagnostic) => diagnostic.manifestPath.toString()),
        [r'$.manifestVersion', r'$.pluginApiVersion'],
      );
    });

    test('defensively copies the supported Plugin API versions', () {
      final supportedVersions = <int>{1};
      final policy = PluginCompatibilityPolicy(
        parser: PluginManifestParser(),
        supportedPluginApiVersions: supportedVersions,
      );
      supportedVersions
        ..clear()
        ..add(99);

      final result = policy.validate(_manifest());

      expect(result.isCompatible, isTrue);
      expect(policy.supportedPluginApiVersions, {1});
      expect(
        () => policy.supportedPluginApiVersions.add(2),
        throwsUnsupportedError,
      );
    });
  });
}

PluginManifest _manifest({int manifestVersion = 1, int pluginApiVersion = 1}) {
  return PluginManifest(
    manifestVersion: ManifestFormatVersion.tryParse(manifestVersion)!,
    id: PluginId.tryParse('dev.shinga.source')!,
    name: 'Source',
    version: PluginVersion.tryParse('1.0.0')!,
    pluginApiVersion: PluginApiVersion.tryParse(pluginApiVersion)!,
    entry: PluginEntryPath.tryParse('index.dart')!,
    permissions: const PluginPermissions(),
    settings: const [],
  );
}
