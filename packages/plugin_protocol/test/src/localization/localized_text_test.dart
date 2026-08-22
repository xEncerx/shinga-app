import 'package:plugin_protocol/plugin_protocol.dart';
import 'package:test/test.dart';

void main() {
  group('LocalizedText', () {
    test('keeps an immutable defensive copy of values', () {
      final locale = LocaleTag.tryParse('en')!;
      final source = <LocaleTag, String>{locale: 'English'};
      final localizedText = LocalizedText(source);

      source[locale] = 'Changed';

      expect(localizedText.values[locale], 'English');
      expect(() => localizedText.values[locale] = 'Changed', throwsUnsupportedError);
    });
  });
}
