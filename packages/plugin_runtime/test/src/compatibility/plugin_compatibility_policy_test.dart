import 'package:plugin_protocol/plugin_protocol.dart';
import 'package:plugin_runtime/plugin_runtime.dart';
import 'package:test/test.dart';

void main() {
  group('PluginCompatibilityPolicy', () {
    test('accepts supported manifest and Plugin API versions', () {
      final policy = PluginCompatibilityPolicy(
        parser: PluginManifestParser(),
        apiRegistry: _apiRegistry(),
      );

      final result = policy.validate(_manifest());

      expect(result.isCompatible, isTrue);
      expect(result.diagnostics, isEmpty);
    });

    test('derives support exclusively from simultaneous API registrations', () {
      final policy = PluginCompatibilityPolicy(
        parser: PluginManifestParser(),
        apiRegistry: _apiRegistry(includeApi2: true),
      );

      expect(policy.validate(_manifest(pluginApiVersion: 2)).isCompatible, isTrue);
      expect(policy.supportedPluginApiVersions, {1, 2});
      expect(() => policy.supportedPluginApiVersions.add(3), throwsUnsupportedError);
    });

    test('reports unsupported manifest and Plugin API versions independently', () {
      final policy = PluginCompatibilityPolicy(
        parser: PluginManifestParser(),
        apiRegistry: _apiRegistry(),
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
  });
}

PluginApiRegistry _apiRegistry({bool includeApi2 = false}) {
  final wireProtocols = PluginWireProtocolRegistry.builtIn();
  return PluginApiRegistry(
    adapters: [
      const PluginApiV1Adapter(),
      if (includeApi2) const _Api2Adapter(),
    ],
    wireProtocols: wireProtocols,
  );
}

final class _Api2Adapter implements PluginApiAdapter {
  const _Api2Adapter();

  @override
  int get pluginApiVersion => 2;

  @override
  int get wireProtocolVersion => 1;
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
