import 'package:plugin_protocol/plugin_protocol.dart';

/// The diagnostics produced while validating plugin package contents.
final class PackageValidationResult {
  /// Creates a validation result from a defensive copy of [diagnostics].
  PackageValidationResult({required List<PackageDiagnostic> diagnostics})
    : diagnostics = List.unmodifiable(diagnostics);

  /// All package diagnostics in reporting order.
  final List<PackageDiagnostic> diagnostics;

  /// Whether no package errors were reported.
  bool get isValid => !diagnostics.hasErrors;
}
