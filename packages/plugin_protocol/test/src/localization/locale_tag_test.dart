import 'package:plugin_protocol/plugin_protocol.dart';
import 'package:test/test.dart';

void main() {
  group('LocaleTag', () {
    test('normalizes language casing', () {
      final locale = LocaleTag.tryParse('EN');

      expect(locale?.language, 'en');
      expect(locale?.script, isNull);
      expect(locale?.region, isNull);
      expect(locale.toString(), 'en');
    });

    test('normalizes script and alphabetic region casing', () {
      final locale = LocaleTag.tryParse('zH-hANS-cn');

      expect(locale?.language, 'zh');
      expect(locale?.script, 'Hans');
      expect(locale?.region, 'CN');
      expect(locale.toString(), 'zh-Hans-CN');
    });

    test('supports numeric regions', () {
      final locale = LocaleTag.tryParse('es-419');

      expect(locale?.language, 'es');
      expect(locale?.script, isNull);
      expect(locale?.region, '419');
      expect(locale.toString(), 'es-419');
    });

    test('rejects unsupported or malformed locale tags', () {
      const invalidTags = [
        '',
        'e',
        'englishxx',
        'en_US',
        'en-',
        '-en',
        'en-us-extra',
        'en-1234',
        'en-Latn-US-extra',
      ];

      for (final tag in invalidTags) {
        expect(LocaleTag.validate(tag), isFalse, reason: tag);
        expect(LocaleTag.tryParse(tag), isNull, reason: tag);
      }
    });

    test('compares tags after normalization', () {
      expect(LocaleTag.tryParse('EN'), LocaleTag.tryParse('en'));
      expect(LocaleTag.tryParse('zh-hans-cn'), LocaleTag.tryParse('ZH-Hans-CN'));
    });
  });
}
