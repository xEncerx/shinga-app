import 'package:plugin_protocol/plugin_protocol.dart';
import 'package:test/test.dart';

void main() {
  group('PluginManifest', () {
    test('stores normalized values without parsing behavior', () {
      final manifest = PluginManifest(
        manifestVersion: ManifestFormatVersion.tryParse(1)!,
        id: PluginId.tryParse('dev.shinga.source')!,
        name: 'Source',
        version: PluginVersion.tryParse('1.2.3')!,
        pluginApiVersion: PluginApiVersion.tryParse(1)!,
        entry: PluginEntryPath.tryParse('dist/index.js')!,
        permissions: const PluginPermissions(),
        settings: const [],
      );

      expect(manifest.manifestVersion.value, 1);
      expect(manifest.id.value, 'dev.shinga.source');
      expect(manifest.name, 'Source');
      expect(manifest.version.value, '1.2.3');
      expect(manifest.pluginApiVersion.value, 1);
      expect(manifest.entry.value, 'dist/index.js');
      expect(manifest.permissions.network, isNull);
      expect(manifest.settings, isEmpty);
    });

    test('keeps an immutable defensive copy of settings', () {
      final settings = <PluginSettingDefinition>[
        TextPluginSettingDefinition(
          id: 'language',
          label: LocalizedText({LocaleTag.tryParse('en')!: 'Language'}),
          required: false,
          defaultValue: 'en',
        ),
      ];
      final manifest = PluginManifest(
        manifestVersion: ManifestFormatVersion.tryParse(1)!,
        id: PluginId.tryParse('dev.shinga.source')!,
        name: 'Source',
        version: PluginVersion.tryParse('1.0.0')!,
        pluginApiVersion: PluginApiVersion.tryParse(1)!,
        entry: PluginEntryPath.tryParse('index.js')!,
        permissions: const PluginPermissions(),
        settings: settings,
      );

      settings.clear();

      expect(manifest.settings, hasLength(1));
      expect(manifest.settings.clear, throwsUnsupportedError);
    });
  });
}
