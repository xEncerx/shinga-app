import 'package:plugin_protocol/plugin_protocol.dart';
import 'package:plugin_protocol/src/common/common.dart';
import 'package:plugin_protocol/src/manifest/parsing/permissions_decoder.dart';
import 'package:test/test.dart';

void main() {
  group('decodePermissions absence behavior', () {
    test('returns no permissions when the permissions object is absent', () {
      final outcome = _decode(null);

      expect(outcome.result, isNotNull);
      expect(outcome.result?.network, isNull);
      expect(outcome.diagnostics.diagnostics, isEmpty);
    });

    test('returns no network access when network is absent', () {
      final outcome = _decode({});

      expect(outcome.result, isNotNull);
      expect(outcome.result?.network, isNull);
      expect(outcome.diagnostics.diagnostics, isEmpty);
    });
  });

  group('decodePermissions network permission', () {
    test('decodes and normalizes exact and wildcard hosts', () {
      final outcome = _decode({
        'network': <String, Object?>{
          'hosts': <Object?>['API.Example.COM', '*.CDN.Example.COM'],
        },
      });

      expect(outcome.result, isNotNull);
      expect(outcome.result?.network?.hosts.map((pattern) => pattern.toString()), [
        'api.example.com',
        '*.cdn.example.com',
      ]);
      expect(outcome.diagnostics.diagnostics, isEmpty);
    });

    test('allows an empty hosts list', () {
      final outcome = _decode({
        'network': <String, Object?>{'hosts': <Object?>[]},
      });

      expect(outcome.result?.network?.hosts, isEmpty);
      expect(outcome.diagnostics.diagnostics, isEmpty);
    });

    test('allows exact and wildcard patterns for the same base host', () {
      final outcome = _decode({
        'network': <String, Object?>{
          'hosts': <Object?>['example.com', '*.example.com'],
        },
      });

      expect(outcome.result?.network?.hosts, hasLength(2));
      expect(outcome.diagnostics.diagnostics, isEmpty);
    });
  });

  group('decodePermissions validation', () {
    test('rejects unknown permissions as errors', () {
      final outcome = _decode({'filesystem': <String, Object?>{}});

      expect(outcome.result, isNull);
      _expectError(
        outcome.diagnostics,
        code: 'manifest.permissions.unknown',
        path: r'$.permissions.filesystem',
        message: 'Unknown permission "filesystem".',
      );
    });

    test('rejects a missing hosts field', () {
      final outcome = _decode({'network': <String, Object?>{}});

      expect(outcome.result, isNull);
      _expectError(
        outcome.diagnostics,
        code: 'manifest.field.missing',
        path: r'$.permissions.network.hosts',
        message: 'Required field is missing.',
      );
    });

    test('rejects wrong network and hosts types', () {
      final wrongNetwork = _decode({'network': 'enabled'});
      final wrongHosts = _decode({
        'network': <String, Object?>{'hosts': 'api.example.com'},
      });

      expect(wrongNetwork.result, isNull);
      expect(wrongHosts.result, isNull);
      expect(wrongNetwork.diagnostics.diagnostics.single.code, 'manifest.field.type_mismatch');
      expect(wrongHosts.diagnostics.diagnostics.single.code, 'manifest.field.type_mismatch');
      expect(wrongNetwork.diagnostics.diagnostics.single.path.toString(), r'$.permissions.network');
      expect(
        wrongHosts.diagnostics.diagnostics.single.path.toString(),
        r'$.permissions.network.hosts',
      );
    });

    test('rejects non-string and invalid host patterns', () {
      final outcome = _decode({
        'network': <String, Object?>{
          'hosts': <Object?>[1, '*', 'https://example.com'],
        },
      });

      expect(outcome.result, isNull);
      expect(outcome.diagnostics.diagnostics.map((item) => item.code), [
        'manifest.field.type_mismatch',
        'manifest.permissions.network.host.invalid',
        'manifest.permissions.network.host.invalid',
      ]);
      expect(outcome.diagnostics.diagnostics.map((item) => item.path.toString()), [
        r'$.permissions.network.hosts[0]',
        r'$.permissions.network.hosts[1]',
        r'$.permissions.network.hosts[2]',
      ]);
    });

    test('rejects duplicate patterns after normalization', () {
      final outcome = _decode({
        'network': <String, Object?>{
          'hosts': <Object?>['API.Example.COM', 'api.example.com'],
        },
      });

      expect(outcome.result, isNull);
      _expectError(
        outcome.diagnostics,
        code: 'manifest.permissions.network.host.duplicate',
        path: r'$.permissions.network.hosts[1]',
        message: 'Network host pattern "api.example.com" is duplicated.',
      );
    });

    test('reports unknown network fields as warnings', () {
      final outcome = _decode({
        'network': <String, Object?>{
          'hosts': <Object?>['api.example.com'],
          'timeout': 30,
        },
      });

      expect(outcome.result, isNotNull);
      expect(outcome.diagnostics.hasErrors, isFalse);
      final warning = outcome.diagnostics.diagnostics.single;
      expect(warning.severity, DiagnosticSeverity.warning);
      expect(warning.code, 'manifest.field.unknown');
      expect(warning.path.toString(), r'$.permissions.network.timeout');
    });
  });
}

({PluginPermissions? result, DiagnosticCollector diagnostics}) _decode(JsonObject? value) {
  final diagnostics = DiagnosticCollector();
  final reader = value == null
      ? null
      : JsonObjectReader(
          value: value,
          path: const JsonPath.root().field('permissions'),
          diagnostics: diagnostics,
        );
  return (result: decodePermissions(reader, diagnostics), diagnostics: diagnostics);
}

void _expectError(
  DiagnosticCollector diagnostics, {
  required String code,
  required String path,
  required String message,
}) {
  final diagnostic = diagnostics.diagnostics.firstWhere((item) => item.code == code);
  expect(diagnostic.severity, DiagnosticSeverity.error);
  expect(diagnostic.path.toString(), path);
  expect(diagnostic.message, message);
}
