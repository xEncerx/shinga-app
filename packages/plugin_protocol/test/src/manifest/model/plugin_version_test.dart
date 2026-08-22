import 'package:plugin_protocol/plugin_protocol.dart';
import 'package:test/test.dart';

void main() {
  group('PluginVersion', () {
    test('accepts Semantic Versioning 2.0.0 versions', () {
      const validVersions = [
        '0.0.0',
        '1.0.0',
        '1.2.3-alpha',
        '1.2.3-alpha.1+build.5',
        '10.20.30-rc.1+sha-abcdef',
      ];

      for (final version in validVersions) {
        expect(PluginVersion.validate(version), isTrue, reason: version);
        expect(PluginVersion.tryParse(version)?.value, version, reason: version);
      }
    });

    test('rejects malformed and non-SemVer versions', () {
      const invalidVersions = [
        '',
        '1',
        '1.0',
        'v1.0.0',
        '01.0.0',
        '1.01.0',
        '1.0.01',
        '1.0.0-',
        '1.0.0-alpha.01',
        '1.0.0+build..1',
      ];

      for (final version in invalidVersions) {
        expect(PluginVersion.validate(version), isFalse, reason: version);
        expect(PluginVersion.tryParse(version), isNull, reason: version);
      }
    });

    test('compares parsed versions by value', () {
      expect(PluginVersion.tryParse('1.2.3'), PluginVersion.tryParse('1.2.3'));
    });

    test('compares SemVer precedence without build metadata', () {
      final stable = PluginVersion.tryParse('1.0.0')!;
      final prerelease = PluginVersion.tryParse('1.0.0-rc.1')!;
      final firstBuild = PluginVersion.tryParse('1.0.0+build.1')!;
      final secondBuild = PluginVersion.tryParse('1.0.0+build.2')!;

      expect(stable.compareTo(prerelease), greaterThan(0));
      expect(firstBuild.compareTo(secondBuild), 0);
    });
  });
}
