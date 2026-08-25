import 'package:plugin_protocol/plugin_protocol.dart';
import 'package:test/test.dart';

void main() {
  group('isPortablePluginPackagePath', () {
    test('accepts canonical package-relative paths', () {
      for (final path in ['index.js', 'dist/index.js', 'assets/cover image.png']) {
        expect(isPortablePluginPackagePath(path), isTrue, reason: path);
      }
    });

    test('rejects traversal, platform separators, and illegal characters', () {
      for (final path in [
        '',
        '/index.js',
        r'dist\index.js',
        '../index.js',
        'dist/./index.js',
        'dist//index.js',
        'index?.js',
        'index\u0000.js',
      ]) {
        expect(isPortablePluginPackagePath(path), isFalse, reason: path);
      }
    });

    test('rejects Windows reserved names and trailing aliases', () {
      for (final path in [
        'CON',
        'con.js',
        'dist/AUX.js',
        'COM1.txt',
        'LPT9.js',
        'COM¹.js',
        r'CLOCK$.js',
        'index.js.',
        'index.js ',
      ]) {
        expect(isPortablePluginPackagePath(path), isFalse, reason: path);
      }
    });
  });
}
