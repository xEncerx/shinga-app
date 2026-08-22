import 'package:plugin_protocol/plugin_protocol.dart';
import 'package:plugin_protocol/src/common/diagnostics/diagnostic_collector.dart';
import 'package:test/test.dart';

void main() {
  group('DiagnosticCollector', () {
    test('assigns different severities to errors and warnings', () {
      final collector = DiagnosticCollector()
        ..warning(
          code: 'deprecated-field',
          path: const JsonPath.root().field('name'),
          message: 'The field is deprecated.',
        )
        ..error(
          code: 'missing-field',
          path: const JsonPath.root().field('id'),
          message: 'The field is required.',
        );

      expect(
        collector.diagnostics.map((diagnostic) => diagnostic.severity),
        [DiagnosticSeverity.warning, DiagnosticSeverity.error],
      );
    });

    test('preserves diagnostic reporting order', () {
      final collector = DiagnosticCollector()
        ..error(
          code: 'first',
          path: const JsonPath.root(),
          message: 'First diagnostic.',
        )
        ..warning(
          code: 'second',
          path: const JsonPath.root(),
          message: 'Second diagnostic.',
        )
        ..error(
          code: 'third',
          path: const JsonPath.root(),
          message: 'Third diagnostic.',
        );

      expect(
        collector.diagnostics.map((diagnostic) => diagnostic.code),
        ['first', 'second', 'third'],
      );
    });

    test('hasErrors ignores warnings', () {
      final collector = DiagnosticCollector()
        ..warning(
          code: 'warning',
          path: const JsonPath.root(),
          message: 'Warning diagnostic.',
        );

      expect(collector.hasErrors, isFalse);

      collector.error(
        code: 'error',
        path: const JsonPath.root(),
        message: 'Error diagnostic.',
      );

      expect(collector.hasErrors, isTrue);
    });
  });
}
