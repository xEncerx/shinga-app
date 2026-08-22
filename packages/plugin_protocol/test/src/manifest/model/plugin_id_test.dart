import 'package:plugin_protocol/plugin_protocol.dart';
import 'package:test/test.dart';

void main() {
  group('PluginId', () {
    test('accepts lowercase reverse-DNS identifiers', () {
      const validIds = [
        'dev.shinga.mangafoo',
        'com.example.source',
        'com.example.manga-foo',
      ];

      for (final id in validIds) {
        expect(PluginId.validate(id), isTrue, reason: id);
        expect(PluginId.tryParse(id)?.value, id, reason: id);
      }
    });

    test('rejects empty, uppercase, malformed, and unsupported identifiers', () {
      const invalidIds = [
        '',
        'mangafoo',
        'Dev.Shİnga.Foo',
        'com..example',
        'com.example.foo!',
        '.com.example',
        'com.example.',
        'com.example_under',
      ];

      for (final id in invalidIds) {
        expect(PluginId.validate(id), isFalse, reason: id);
        expect(PluginId.tryParse(id), isNull, reason: id);
      }
    });

    test('enforces DNS length limits', () {
      final maxLengthId = List.filled(127, 'a').join('.');
      final tooLongId = '$maxLengthId.a';
      final tooLongSegment = 'com.${List.filled(64, 'a').join()}';

      expect(maxLengthId.length, 253);
      expect(PluginId.validate(maxLengthId), isTrue);
      expect(PluginId.validate(tooLongId), isFalse);
      expect(PluginId.validate(tooLongSegment), isFalse);
    });

    test('compares parsed identifiers by value', () {
      expect(
        PluginId.tryParse('dev.shinga.mangafoo'),
        PluginId.tryParse('dev.shinga.mangafoo'),
      );
    });
  });
}
