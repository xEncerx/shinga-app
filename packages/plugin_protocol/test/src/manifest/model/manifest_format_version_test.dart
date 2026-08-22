import 'package:plugin_protocol/plugin_protocol.dart';
import 'package:test/test.dart';

void main() {
  group('ManifestFormatVersion', () {
    test('accepts positive integers', () {
      for (final version in [1, 2, 100]) {
        expect(ManifestFormatVersion.validate(version), isTrue);
        expect(ManifestFormatVersion.tryParse(version)?.value, version);
      }
    });

    test('rejects zero and negative integers', () {
      for (final version in [0, -1, -100]) {
        expect(ManifestFormatVersion.validate(version), isFalse);
        expect(ManifestFormatVersion.tryParse(version), isNull);
      }
    });

    test('compares parsed versions by value', () {
      expect(ManifestFormatVersion.tryParse(1), ManifestFormatVersion.tryParse(1));
    });
  });
}
