import 'package:plugin_protocol/plugin_protocol.dart';
import 'package:plugin_protocol/src/common/common.dart';
import 'package:plugin_protocol/src/localization/localized_text_decoder.dart';
import 'package:test/test.dart';

void main() {
  group('decodeLocalizedText', () {
    test('decodes values using normalized locale tags', () {
      final diagnostics = DiagnosticCollector();
      final reader = _reader({
        'EN': 'English',
        'zh-hans-cn': '简体中文',
        'es-419': 'Español latinoamericano',
      }, diagnostics);

      final result = decodeLocalizedText(reader, diagnostics);

      expect(result, isNotNull);
      expect(result?.values.keys.map((locale) => locale.toString()), [
        'en',
        'zh-Hans-CN',
        'es-419',
      ]);
      expect(result?.values[LocaleTag.tryParse('en')], 'English');
      expect(diagnostics.diagnostics, isEmpty);
    });

    test('rejects an empty object', () {
      final diagnostics = DiagnosticCollector();

      final result = decodeLocalizedText(_reader({}, diagnostics), diagnostics);

      expect(result, isNull);
      _expectDiagnostic(
        diagnostics.diagnostics.single,
        code: 'manifest.localized_text.empty',
        path: r'$.label',
        message: 'Localized text must contain at least one value.',
      );
    });

    test('rejects invalid locale tags', () {
      final diagnostics = DiagnosticCollector();

      final result = decodeLocalizedText(
        _reader({'en_US': 'English'}, diagnostics),
        diagnostics,
      );

      expect(result, isNull);
      _expectDiagnostic(
        diagnostics.diagnostics.single,
        code: 'manifest.localized_text.invalid_locale',
        path: r'$.label.en_US',
        message: 'Invalid locale tag "en_US".',
      );
    });

    test('rejects empty and whitespace-only strings', () {
      final diagnostics = DiagnosticCollector();

      final result = decodeLocalizedText(
        _reader({'en': '', 'ru': '   '}, diagnostics),
        diagnostics,
      );

      expect(result, isNull);
      expect(diagnostics.diagnostics.map((item) => item.code), [
        'manifest.localized_text.empty_value',
        'manifest.localized_text.empty_value',
      ]);
      expect(diagnostics.diagnostics.map((item) => item.path.toString()), [
        r'$.label.en',
        r'$.label.ru',
      ]);
    });

    test('rejects duplicate locales after normalization', () {
      final diagnostics = DiagnosticCollector();

      final result = decodeLocalizedText(
        _reader({'EN': 'English', 'en': 'Duplicate'}, diagnostics),
        diagnostics,
      );

      expect(result, isNull);
      _expectDiagnostic(
        diagnostics.diagnostics.single,
        code: 'manifest.localized_text.duplicate_locale',
        path: r'$.label.en',
        message: 'Locale "en" is duplicated after normalization.',
      );
    });

    test('reports non-string values without throwing', () {
      final diagnostics = DiagnosticCollector();

      final result = decodeLocalizedText(
        _reader({'en': 1, 'ru': 'Русский'}, diagnostics),
        diagnostics,
      );

      expect(result, isNull);
      _expectDiagnostic(
        diagnostics.diagnostics.single,
        code: 'manifest.field.type_mismatch',
        path: r'$.label.en',
        message: 'Expected string, got integer.',
      );
    });
  });
}

JsonObjectReader _reader(JsonObject value, DiagnosticCollector diagnostics) {
  return JsonObjectReader(
    value: value,
    path: const JsonPath.root().field('label'),
    diagnostics: diagnostics,
  );
}

void _expectDiagnostic(
  ManifestDiagnostic diagnostic, {
  required String code,
  required String path,
  required String message,
}) {
  expect(diagnostic.code, code);
  expect(diagnostic.path.toString(), path);
  expect(diagnostic.message, message);
}
