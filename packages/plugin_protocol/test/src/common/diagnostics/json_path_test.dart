import 'package:plugin_protocol/plugin_protocol.dart';
import 'package:test/test.dart';

void main() {
  group('JsonPath', () {
    test('formats the root path', () {
      expect(const JsonPath.root().toString(), r'$');
    });

    test('formats field and index segments', () {
      final path = const JsonPath.root()
          .field('settings')
          .index(0)
          .field('options')
          .index(1)
          .field('label');

      expect(path.toString(), r'$.settings[0].options[1].label');
    });

    test('uses bracket notation for non-identifier field names', () {
      final path = const JsonPath.root().field('content.language').field('display name');

      expect(path.toString(), r'$["content.language"]["display name"]');
    });
  });
}
