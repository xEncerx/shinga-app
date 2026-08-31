import 'package:plugin_protocol/plugin_protocol.dart';
import 'package:test/test.dart';

void main() {
  group('PluginEntryPath', () {
    test('accepts relative Dart paths', () {
      const validPaths = [
        'index.dart',
        'src/index.dart',
        'dist/plugin/main.dart',
        'dist/plugin..debug.dart',
      ];

      for (final path in validPaths) {
        expect(PluginEntryPath.validate(path), isTrue, reason: path);
        expect(PluginEntryPath.tryParse(path)?.value, path, reason: path);
      }
    });

    test('rejects parent traversal and non-canonical segments', () {
      const invalidPaths = [
        '../index.dart',
        'src/../index.dart',
        './index.dart',
        'src//index.dart',
      ];

      for (final path in invalidPaths) {
        expect(PluginEntryPath.validate(path), isFalse, reason: path);
        expect(PluginEntryPath.tryParse(path), isNull, reason: path);
      }
    });

    test('rejects absolute, Windows, and URL paths', () {
      const invalidPaths = [
        '/index.dart',
        r'\server\share\index.dart',
        r'C:\plugins\index.dart',
        r'src\index.dart',
        'https://example.com/index.dart',
        'file:index.dart',
      ];

      for (final path in invalidPaths) {
        expect(PluginEntryPath.validate(path), isFalse, reason: path);
      }
    });

    test('rejects Windows reserved and non-portable paths', () {
      const invalidPaths = [
        'CON.dart',
        'dist/aux.dart',
        'COM1.dart',
        'LPT9.dart',
        'index?.dart',
        'index.dart.',
        'index.dart ',
      ];

      for (final path in invalidPaths) {
        expect(PluginEntryPath.validate(path), isFalse, reason: path);
      }
    });

    test('requires a Dart extension and a non-empty path', () {
      const invalidPaths = ['', 'index.js', 'index.json', 'index.DART', 'index.dart?debug=true'];

      for (final path in invalidPaths) {
        expect(PluginEntryPath.validate(path), isFalse, reason: path);
      }
    });

    test('rejects null bytes', () {
      expect(PluginEntryPath.validate('index\u0000.dart'), isFalse);
    });

    test('compares parsed paths by value', () {
      expect(PluginEntryPath.tryParse('index.dart'), PluginEntryPath.tryParse('index.dart'));
    });
  });
}
