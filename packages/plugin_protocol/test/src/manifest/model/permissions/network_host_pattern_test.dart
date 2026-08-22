import 'package:plugin_protocol/plugin_protocol.dart';
import 'package:test/test.dart';

void main() {
  group('NetworkHostPattern exact hosts', () {
    test('matches only the exact host', () {
      final pattern = NetworkHostPattern.tryParse('api.example.com')!;

      expect(pattern.matches('api.example.com'), isTrue);
      expect(pattern.matches('evil.example.com'), isFalse);
      expect(pattern.matches('images.api.example.com'), isFalse);
    });

    test('normalizes pattern and requested host casing', () {
      final pattern = NetworkHostPattern.tryParse('API.Example.COM')!;

      expect(pattern.host, 'api.example.com');
      expect(pattern.includeSubdomains, isFalse);
      expect(pattern.matches('Api.Example.Com'), isTrue);
      expect(pattern.toString(), 'api.example.com');
    });
  });

  group('NetworkHostPattern wildcard hosts', () {
    test('matches nested subdomains but not the base or lookalike domains', () {
      final pattern = NetworkHostPattern.tryParse('*.example.com')!;

      expect(pattern.matches('api.example.com'), isTrue);
      expect(pattern.matches('images.api.example.com'), isTrue);
      expect(pattern.matches('example.com'), isFalse);
      expect(pattern.matches('evil-example.com'), isFalse);
    });

    test('stores a normalized host separately from wildcard behavior', () {
      final pattern = NetworkHostPattern.tryParse('*.Example.COM')!;

      expect(pattern.host, 'example.com');
      expect(pattern.includeSubdomains, isTrue);
      expect(pattern.toString(), '*.example.com');
    });
  });

  group('NetworkHostPattern validation', () {
    test('rejects unsafe and malformed patterns', () {
      const invalidPatterns = [
        '',
        '*',
        '*.*',
        'https://example.com',
        'example.com/path',
        'example.com:8080',
        '../example.com',
        'example..com',
        '-example.com',
        'example.com-',
        'example_com',
      ];

      for (final pattern in invalidPatterns) {
        expect(NetworkHostPattern.validate(pattern), isFalse, reason: pattern);
        expect(NetworkHostPattern.tryParse(pattern), isNull, reason: pattern);
      }
    });

    test('rejects unsafe requested hosts without throwing', () {
      final pattern = NetworkHostPattern.tryParse('*.example.com')!;

      for (final host in [
        '*',
        'https://api.example.com',
        'api.example.com:443',
        '../api.example.com',
      ]) {
        expect(pattern.matches(host), isFalse, reason: host);
      }
    });

    test('compares normalized patterns by value', () {
      expect(
        NetworkHostPattern.tryParse('*.EXAMPLE.COM'),
        NetworkHostPattern.tryParse('*.example.com'),
      );
      expect(
        NetworkHostPattern.tryParse('example.com'),
        isNot(NetworkHostPattern.tryParse('*.example.com')),
      );
    });
  });
}
