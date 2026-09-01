import 'package:plugin_protocol/plugin_protocol.dart';
import 'package:plugin_protocol/src/common/common.dart';
import 'package:plugin_protocol/src/manifest/parsing/manifest_v1_decoder.dart';
import 'package:test/test.dart';

void main() {
  group('decodeManifestV1 valid manifests', () {
    test('decodes required fields and applies optional defaults', () {
      final outcome = _decode(_minimalManifest());

      expect(outcome.manifest, isNotNull);
      expect(outcome.manifest?.manifestVersion.value, 1);
      expect(outcome.manifest?.id.value, 'dev.shinga.source');
      expect(outcome.manifest?.name, 'Source');
      expect(outcome.manifest?.version.value, '1.0.0');
      expect(outcome.manifest?.pluginApiVersion.value, 1);
      expect(outcome.manifest?.entry.value, 'index.dart');
      expect(outcome.manifest?.icon, isNull);
      expect(outcome.manifest?.permissions.network, isNull);
      expect(outcome.manifest?.settings, isEmpty);
      expect(outcome.diagnostics.diagnostics, isEmpty);
    });

    test('accepts a safe JavaScript entry path without selecting an engine', () {
      final outcome = _decode(_minimalManifest()..['entry'] = 'dist/main.js');

      expect(outcome.manifest?.entry.value, 'dist/main.js');
      expect(outcome.diagnostics.diagnostics, isEmpty);
    });

    test('preserves icons with every supported image extension', () {
      const icons = [
        'https://example.com/icon.ico',
        'http://example.com/icon.GIF',
        'https://example.com/icon.webp',
        'https://example.com/icon.PNG?size=128#preview',
        'https://example.com/icon.jpg',
        'https://example.com/icon.JPEG',
        'https://example.com/icon.avif',
        'https://example.com/icon.BMP',
        'https://example.com/icon.svg',
        'https://example.com/icon.SVGZ',
        'https://example.com/icon.tif',
        'https://example.com/icon.TIFF',
        'https://example.com/icon.apng',
      ];

      for (final icon in icons) {
        final outcome = _decode(_minimalManifest()..['icon'] = icon);

        expect(outcome.manifest?.icon, icon, reason: icon);
        expect(outcome.diagnostics.diagnostics, isEmpty, reason: icon);
      }
    });

    test('delegates permissions and settings decoding', () {
      final manifest = _minimalManifest()
        ..['entry'] = 'dist/main.dart'
        ..['permissions'] = <String, Object?>{
          'network': <String, Object?>{
            'hosts': <Object?>['API.Example.COM'],
          },
        }
        ..['settings'] = <Object?>[
          <String, Object?>{
            'id': 'language',
            'type': 'select',
            'label': <String, Object?>{'en': 'Language'},
            'defaultValue': 'en',
            'options': <Object?>[
              <String, Object?>{
                'value': 'en',
                'label': <String, Object?>{'en': 'English'},
              },
            ],
          },
        ];

      final outcome = _decode(manifest);

      expect(outcome.manifest?.entry.value, 'dist/main.dart');
      expect(outcome.manifest?.permissions.network?.hosts.single.host, 'api.example.com');
      expect(outcome.manifest?.settings.single, isA<SelectPluginSettingDefinition>());
      expect(outcome.diagnostics.diagnostics, isEmpty);
    });

    test('keeps unknown top-level fields as warnings', () {
      final manifest = _minimalManifest()..['description'] = 'Example source';

      final outcome = _decode(manifest);

      expect(outcome.manifest, isNotNull);
      expect(outcome.diagnostics.hasErrors, isFalse);
      final warning = outcome.diagnostics.diagnostics.single;
      expect(warning.code, 'manifest.field.unknown');
      expect(warning.path.toString(), r'$.description');
    });
  });

  group('decodeManifestV1 validation', () {
    test('requires an explicit entry', () {
      final outcome = _decode(_minimalManifest()..remove('entry'));

      expect(outcome.manifest, isNull);
      _expectError(
        outcome.diagnostics,
        code: 'manifest.field.missing',
        path: r'$.entry',
      );
    });

    test('rejects duplicate setting ids', () {
      final setting = <String, Object?>{
        'id': 'token',
        'type': 'text',
        'label': <String, Object?>{'en': 'Token'},
      };
      final manifest = _minimalManifest()
        ..['settings'] = <Object?>[setting, Map<String, Object?>.of(setting)];

      final outcome = _decode(manifest);

      expect(outcome.manifest, isNull);
      _expectError(
        outcome.diagnostics,
        code: 'manifest.setting.id.duplicate',
        path: r'$.settings[1].id',
      );
    });

    test('rejects invalid normalized top-level values', () {
      final manifest = _minimalManifest()
        ..['id'] = 'invalid'
        ..['name'] = '   '
        ..['version'] = 'v1'
        ..['pluginApiVersion'] = 0
        ..['entry'] = 'https://example.com/index.dart';

      final outcome = _decode(manifest);

      expect(outcome.manifest, isNull);
      expect(outcome.diagnostics.diagnostics.map((item) => item.code), [
        'manifest.id.invalid',
        'manifest.name.empty',
        'manifest.plugin_version.invalid',
        'manifest.plugin_api_version.invalid',
        'manifest.entry.invalid',
      ]);
    });

    test('rejects a version other than version 1 when called directly', () {
      final manifest = _minimalManifest()..['manifestVersion'] = 2;

      final outcome = _decode(manifest);

      expect(outcome.manifest, isNull);
      _expectError(
        outcome.diagnostics,
        code: 'manifest.version.unexpected',
        path: r'$.manifestVersion',
      );
    });

    test('propagates specialized decoder errors', () {
      final manifest = _minimalManifest()
        ..['permissions'] = <String, Object?>{
          'filesystem': <String, Object?>{},
        }
        ..['settings'] = <Object?>[
          <String, Object?>{
            'id': 'broken',
            'type': 'unknown',
            'label': <String, Object?>{'en': 'Broken'},
          },
        ];

      final outcome = _decode(manifest);

      expect(outcome.manifest, isNull);
      expect(outcome.diagnostics.diagnostics.map((item) => item.code), [
        'manifest.permissions.unknown',
        'manifest.setting.type.unknown',
      ]);
    });

    test('rejects a malformed settings field', () {
      final manifest = _minimalManifest()..['settings'] = 'invalid';

      final outcome = _decode(manifest);

      expect(outcome.manifest, isNull);
      _expectError(
        outcome.diagnostics,
        code: 'manifest.field.type_mismatch',
        path: r'$.settings',
      );
    });

    test('rejects a non-string icon', () {
      final outcome = _decode(_minimalManifest()..['icon'] = 42);

      expect(outcome.manifest, isNull);
      _expectError(
        outcome.diagnostics,
        code: 'manifest.field.type_mismatch',
        path: r'$.icon',
      );
    });

    test('rejects invalid or unsupported icon URLs', () {
      const icons = [
        'images/icon.png',
        'ftp://example.com/icon.png',
        'https:///icon.png',
        'https://[invalid/icon.png',
        'https://example.com/icon',
        'https://example.com/icon.txt',
        'https://example.com/icon.png.exe',
      ];

      for (final icon in icons) {
        final outcome = _decode(_minimalManifest()..['icon'] = icon);

        expect(outcome.manifest, isNull, reason: icon);
        _expectError(
          outcome.diagnostics,
          code: 'manifest.icon.invalid',
          path: r'$.icon',
        );
      }
    });
  });
}

({PluginManifest? manifest, DiagnosticCollector diagnostics}) _decode(JsonObject value) {
  final diagnostics = DiagnosticCollector();
  final reader = JsonObjectReader(
    value: value,
    path: const JsonPath.root(),
    diagnostics: diagnostics,
  );
  return (
    manifest: decodeManifestV1(reader, diagnostics),
    diagnostics: diagnostics,
  );
}

JsonObject _minimalManifest() {
  return <String, Object?>{
    'manifestVersion': 1,
    'id': 'dev.shinga.source',
    'name': 'Source',
    'version': '1.0.0',
    'pluginApiVersion': 1,
    'entry': 'index.dart',
  };
}

void _expectError(
  DiagnosticCollector diagnostics, {
  required String code,
  required String path,
}) {
  final diagnostic = diagnostics.diagnostics.firstWhere((item) => item.code == code);
  expect(diagnostic.severity, DiagnosticSeverity.error);
  expect(diagnostic.path.toString(), path);
}
