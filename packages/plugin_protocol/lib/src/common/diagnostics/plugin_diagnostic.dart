/// A stable, machine-readable diagnostic identifier.
typedef DiagnosticCode = String;

/// The severity of a plugin diagnostic.
enum DiagnosticSeverity {
  /// A non-fatal plugin issue.
  warning,

  /// A plugin issue that prevents successful validation.
  error,
}

/// Describes an issue discovered while inspecting a plugin.
abstract interface class PluginDiagnostic {
  /// The stable identifier of this kind of issue.
  DiagnosticCode get code;

  /// The impact of the issue on plugin processing.
  DiagnosticSeverity get severity;

  /// The human-readable explanation of the issue.
  String get message;
}

/// Provides aggregate checks for a sequence of plugin diagnostics.
extension PluginDiagnostics on Iterable<PluginDiagnostic> {
  /// Whether the sequence contains at least one error diagnostic.
  bool get hasErrors => any(
    (diagnostic) => diagnostic.severity == DiagnosticSeverity.error,
  );
}
