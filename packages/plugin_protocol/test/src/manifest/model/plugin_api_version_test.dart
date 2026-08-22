import 'package:plugin_protocol/plugin_protocol.dart';
import 'package:test/test.dart';

void main() {
  group('PluginApiVersion', () {
    test('accepts positive integers', () {
      for (final version in [1, 2, 100]) {
        expect(PluginApiVersion.validate(version), isTrue);
        expect(PluginApiVersion.tryParse(version)?.value, version);
      }
    });

    test('rejects zero and negative integers', () {
      for (final version in [0, -1, -100]) {
        expect(PluginApiVersion.validate(version), isFalse);
        expect(PluginApiVersion.tryParse(version), isNull);
      }
    });

    test('compares parsed versions by value', () {
      expect(PluginApiVersion.tryParse(1), PluginApiVersion.tryParse(1));
    });
  });
}
