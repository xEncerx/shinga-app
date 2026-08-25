import 'package:plugin_protocol/plugin_protocol.dart';
import 'package:test/test.dart';

void main() {
  group('PluginEntryPath', () {
    test('accepts relative JavaScript paths', () {
      const validPaths = [
        'index.js',
        'src/index.js',
        'dist/plugin/main.js',
        'dist/plugin..debug.js',
      ];

      for (final path in validPaths) {
        expect(PluginEntryPath.validate(path), isTrue, reason: path);
        expect(PluginEntryPath.tryParse(path)?.value, path, reason: path);
      }
    });

    test('rejects parent traversal and non-canonical segments', () {
      const invalidPaths = [
        '../index.js',
        'src/../index.js',
        './index.js',
        'src//index.js',
      ];

      for (final path in invalidPaths) {
        expect(PluginEntryPath.validate(path), isFalse, reason: path);
        expect(PluginEntryPath.tryParse(path), isNull, reason: path);
      }
    });

    test('rejects absolute, Windows, and URL paths', () {
      const invalidPaths = [
        '/index.js',
        r'\server\share\index.js',
        r'C:\plugins\index.js',
        r'src\index.js',
        'https://example.com/index.js',
        'file:index.js',
      ];

      for (final path in invalidPaths) {
        expect(PluginEntryPath.validate(path), isFalse, reason: path);
      }
    });

    test('rejects Windows reserved and non-portable paths', () {
      const invalidPaths = [
        'CON.js',
        'dist/aux.js',
        'COM1.js',
        'LPT9.js',
        'index?.js',
        'index.js.',
        'index.js ',
      ];

      for (final path in invalidPaths) {
        expect(PluginEntryPath.validate(path), isFalse, reason: path);
      }
    });

    test('requires a JavaScript extension and a non-empty path', () {
      const invalidPaths = ['', 'index.ts', 'index.json', 'index.JS', 'index.js?debug=true'];

      for (final path in invalidPaths) {
        expect(PluginEntryPath.validate(path), isFalse, reason: path);
      }
    });

    test('rejects null bytes', () {
      expect(PluginEntryPath.validate('index\u0000.js'), isFalse);
    });

    test('compares parsed paths by value', () {
      expect(PluginEntryPath.tryParse('index.js'), PluginEntryPath.tryParse('index.js'));
    });
  });
}
