import 'package:plugin_protocol/src/common/common.dart';

/// Collects manifest diagnostics in the order they are reported.
final class DiagnosticCollector {
  final List<ManifestDiagnostic> _diagnostics = [];

  /// The collected diagnostics in reporting order.
  List<ManifestDiagnostic> get diagnostics => List.unmodifiable(_diagnostics);

  /// Whether at least one error has been reported.
  bool get hasErrors => _diagnostics.hasErrors;

  /// Whether an error was added at or after [initialDiagnosticCount].
  bool hasErrorsSince(int initialDiagnosticCount) {
    return diagnostics.skip(initialDiagnosticCount).hasErrors;
  }

  /// Reports a missing required field at [path].
  void reportMissingField(JsonPath path) {
    error(
      code: 'manifest.field.missing',
      path: path,
      message: 'Required field is missing.',
    );
  }

  /// Reports that [actual] does not have the [expected] JSON type.
  void reportTypeMismatch({
    required JsonPath path,
    required String expected,
    required Object? actual,
  }) {
    error(
      code: 'manifest.field.type_mismatch',
      path: path,
      message: 'Expected $expected, got ${_jsonTypeName(actual)}.',
    );
  }

  /// Reports an error at [path].
  void error({
    required DiagnosticCode code,
    required JsonPath path,
    required String message,
  }) {
    _add(
      code: code,
      severity: DiagnosticSeverity.error,
      path: path,
      message: message,
    );
  }

  /// Reports a warning at [path].
  void warning({
    required DiagnosticCode code,
    required JsonPath path,
    required String message,
  }) {
    _add(
      code: code,
      severity: DiagnosticSeverity.warning,
      path: path,
      message: message,
    );
  }

  void _add({
    required DiagnosticCode code,
    required DiagnosticSeverity severity,
    required JsonPath path,
    required String message,
  }) {
    _diagnostics.add(
      ManifestDiagnostic(
        code: code,
        severity: severity,
        path: path,
        message: message,
      ),
    );
  }
}

/// Returns a stable human-readable name for a JSON value type.
String _jsonTypeName(Object? value) {
  return switch (value) {
    null => 'null',
    String() => 'string',
    int() => 'integer',
    num() => 'number',
    bool() => 'boolean',
    JsonObject() => 'object',
    JsonArray() => 'array',
    _ => 'unsupported value',
  };
}
