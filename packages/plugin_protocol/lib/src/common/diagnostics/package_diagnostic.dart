import 'package:plugin_protocol/src/common/diagnostics/json_path.dart';
import 'package:plugin_protocol/src/common/diagnostics/plugin_diagnostic.dart';

/// Describes an issue found while inspecting plugin package contents.
final class PackageDiagnostic implements PluginDiagnostic {
  /// Creates a package diagnostic.
  const PackageDiagnostic({
    required this.code,
    required this.severity,
    required this.message,
    this.relativePath,
    this.manifestPath,
  }) : assert(
         relativePath != null || manifestPath != null,
         'A package diagnostic must identify a package or manifest location.',
       );

  /// Creates a package diagnostic with severity `error`.
  const PackageDiagnostic.error({
    required this.code,
    required this.message,
    this.relativePath,
    this.manifestPath,
  }) : severity = DiagnosticSeverity.error,
       assert(
         relativePath != null || manifestPath != null,
         'A package diagnostic must identify a package or manifest location.',
       );

  @override
  final DiagnosticCode code;

  @override
  final DiagnosticSeverity severity;

  @override
  final String message;

  /// The package-relative path associated with the issue, when available.
  final String? relativePath;

  /// The related manifest field, when the package path comes from the manifest.
  final JsonPath? manifestPath;
}
