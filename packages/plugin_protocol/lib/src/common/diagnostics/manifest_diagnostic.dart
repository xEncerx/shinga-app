import 'package:plugin_protocol/src/common/diagnostics/json_path.dart';
import 'package:plugin_protocol/src/common/diagnostics/plugin_diagnostic.dart';

/// Describes an issue found while processing a plugin manifest.
final class ManifestDiagnostic implements PluginDiagnostic {
  /// Creates a manifest diagnostic.
  const ManifestDiagnostic({
    required this.code,
    required this.severity,
    required this.path,
    required this.message,
  });

  /// The stable identifier of this kind of issue.
  @override
  final DiagnosticCode code;

  /// The impact of the issue on manifest processing.
  @override
  final DiagnosticSeverity severity;

  /// The location of the issue in the source JSON.
  final JsonPath path;

  /// The human-readable explanation of the issue.
  @override
  final String message;
}
