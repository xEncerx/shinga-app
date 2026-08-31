import 'dart:convert';

import 'package:plugin_protocol/plugin_protocol.dart';
import 'package:test/test.dart';

void main() {
  group('PluginManifestParser JSON handling', () {
    test('parses a valid version 1 manifest', () {
      final manifest = _minimalManifest()
        ..['icon'] = 'https://cdn.example.com/source.SVG?version=1#icon';

      final result = PluginManifestParser().parse(jsonEncode(manifest));

      expect(result.isSuccess, isTrue);
      expect(result.hasErrors, isFalse);
      expect(result.manifest?.id.value, 'dev.shinga.source');
      expect(result.manifest?.entry.value, 'index.dart');
      expect(result.manifest?.icon, 'https://cdn.example.com/source.SVG?version=1#icon');
      expect(result.diagnostics, isEmpty);
    });

    test('invalidates the full manifest for an invalid icon', () {
      final manifest = _minimalManifest()..['icon'] = 'https://example.com/icon.json';

      final result = PluginManifestParser().parse(jsonEncode(manifest));

      expect(result.isSuccess, isFalse);
      expect(result.manifest, isNull);
      expect(result.diagnostics.single.code, 'manifest.icon.invalid');
      expect(result.diagnostics.single.path.toString(), r'$.icon');
    });

    test('reports malformed JSON without throwing', () {
      final result = PluginManifestParser().parse('{"manifestVersion": 1');

      expect(result.isSuccess, isFalse);
      expect(result.manifest, isNull);
      expect(result.diagnostics.single.code, 'manifest.json.invalid');
      expect(result.diagnostics.single.path.toString(), r'$');
    });

    test('requires an object at the document root', () {
      for (final source in ['[]', 'null', '"manifest"']) {
        final result = PluginManifestParser().parse(source);

        expect(result.manifest, isNull, reason: source);
        expect(result.diagnostics.single.code, 'manifest.field.type_mismatch', reason: source);
        expect(result.diagnostics.single.path.toString(), r'$', reason: source);
      }
    });
  });

  group('PluginManifestParser version dispatch', () {
    test('reports a missing manifest version', () {
      final result = PluginManifestParser().parse('{}');

      expect(result.manifest, isNull);
      expect(result.diagnostics.single.code, 'manifest.field.missing');
      expect(result.diagnostics.single.path.toString(), r'$.manifestVersion');
    });

    test('reports a non-integer manifest version', () {
      final result = PluginManifestParser().parse('{"manifestVersion":"1"}');

      expect(result.manifest, isNull);
      expect(result.diagnostics.single.code, 'manifest.field.type_mismatch');
      expect(result.diagnostics.single.path.toString(), r'$.manifestVersion');
    });

    test('rejects non-positive manifest versions', () {
      final result = PluginManifestParser().parse('{"manifestVersion":0}');

      expect(result.manifest, isNull);
      expect(result.diagnostics.single.code, 'manifest.version.invalid');
    });

    test('does not dispatch unsupported manifest versions', () {
      final result = PluginManifestParser().parse('{"manifestVersion":2}');

      expect(result.manifest, isNull);
      expect(result.diagnostics, hasLength(1));
      expect(result.diagnostics.single.code, 'manifest.version.unsupported');
      expect(result.diagnostics.single.path.toString(), r'$.manifestVersion');
    });
  });

  group('PluginManifestParser result', () {
    test('preserves warnings on a successful parse', () {
      final manifest = _minimalManifest()..['futureField'] = true;

      final result = PluginManifestParser().parse(jsonEncode(manifest));

      expect(result.isSuccess, isTrue);
      expect(result.manifest, isNotNull);
      expect(result.diagnostics.single.severity, DiagnosticSeverity.warning);
      expect(result.diagnostics.single.path.toString(), r'$.futureField');
    });

    test('does not perform API compatibility checks', () {
      final manifest = _minimalManifest()..['pluginApiVersion'] = 999;

      final result = PluginManifestParser().parse(jsonEncode(manifest));

      expect(result.isSuccess, isTrue);
      expect(result.manifest?.pluginApiVersion.value, 999);
    });

    test('exposes immutable diagnostics', () {
      final result = PluginManifestParser().parse('{}');

      expect(result.diagnostics.clear, throwsUnsupportedError);
    });

    test('preserves setting descriptions through the complete parser', () {
      const source = '**Needed** for remote authentication.\n';
      final manifest = _minimalManifest()
        ..['settings'] = <Object?>[
          <String, Object?>{
            'id': 'token',
            'type': 'secret',
            'label': <String, Object?>{'en': 'Token'},
            'description': <String, Object?>{'EN': source},
          },
        ];

      final result = PluginManifestParser().parse(jsonEncode(manifest));

      expect(result.isSuccess, isTrue);
      expect(
        result.manifest?.settings.single.description?.values[LocaleTag.tryParse('en')],
        source,
      );
      expect(result.diagnostics, isEmpty);
    });

    test('invalidates the full manifest for an over-limit setting description', () {
      final manifest = _minimalManifest()
        ..['settings'] = <Object?>[
          <String, Object?>{
            'id': 'token',
            'type': 'secret',
            'label': <String, Object?>{'en': 'Token'},
            'description': <String, Object?>{'EN': 'a' * 4001},
          },
        ];

      final result = PluginManifestParser().parse(jsonEncode(manifest));

      expect(result.isSuccess, isFalse);
      expect(result.manifest, isNull);
      expect(result.diagnostics.single.code, 'manifest.setting.description.too_long');
      expect(
        result.diagnostics.single.path.toString(),
        r'$.settings[0].description.EN',
      );
      expect(
        result.diagnostics.single.message,
        'Setting description must not exceed 4000 characters.',
      );
    });
  });
}

Map<String, Object?> _minimalManifest() {
  return <String, Object?>{
    'manifestVersion': 1,
    'id': 'dev.shinga.source',
    'name': 'Source',
    'version': '1.0.0',
    'pluginApiVersion': 1,
  };
}
