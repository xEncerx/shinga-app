import 'package:plugin_protocol/plugin_protocol.dart';
import 'package:test/test.dart';

void main() {
  group('PluginDiagnostic', () {
    test('is implemented by manifest and package diagnostics', () {
      const manifest = ManifestDiagnostic(
        code: 'manifest.test',
        severity: DiagnosticSeverity.warning,
        path: JsonPath.root(),
        message: 'Manifest warning.',
      );
      const package = PackageDiagnostic(
        code: 'plugin.package.test',
        severity: DiagnosticSeverity.error,
        relativePath: 'index.js',
        message: 'Package error.',
      );

      expect(<PluginDiagnostic>[manifest, package], hasLength(2));
      expect(package.relativePath, 'index.js');
    });

    test('reports whether an iterable contains errors', () {
      const warning = ManifestDiagnostic(
        code: 'manifest.warning',
        severity: DiagnosticSeverity.warning,
        path: JsonPath.root(),
        message: 'Warning.',
      );
      const error = PackageDiagnostic(
        code: 'plugin.package.error',
        severity: DiagnosticSeverity.error,
        relativePath: 'manifest.json',
        message: 'Error.',
      );

      expect(const <PluginDiagnostic>[].hasErrors, isFalse);
      expect(const <ManifestDiagnostic>[warning].hasErrors, isFalse);
      expect(const <PluginDiagnostic>[warning, error].hasErrors, isTrue);
    });
  });
}
