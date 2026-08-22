import 'package:plugin_protocol/plugin_protocol.dart';

/// The diagnostics produced by plugin compatibility validation.
final class CompatibilityResult {
  /// Creates a compatibility result from a defensive copy of [diagnostics].
  CompatibilityResult({required List<PackageDiagnostic> diagnostics})
    : diagnostics = List.unmodifiable(diagnostics);

  /// All compatibility diagnostics in reporting order.
  final List<PackageDiagnostic> diagnostics;

  /// Whether the plugin is compatible with the current runtime.
  bool get isCompatible => !diagnostics.hasErrors;
}
