import 'package:plugin_protocol/plugin_protocol.dart';
import 'package:plugin_runtime/src/execution/plugin_executable_artifact.dart';

/// The diagnostics produced while validating plugin package contents.
final class PackageValidationResult {
  /// Creates a validation result from a defensive copy of [diagnostics].
  PackageValidationResult({
    required List<PackageDiagnostic> diagnostics,
    this.artifact,
  }) : diagnostics = List.unmodifiable(diagnostics);

  /// All package diagnostics in reporting order.
  final List<PackageDiagnostic> diagnostics;

  /// The exact executable artifact when validation succeeded.
  final PluginExecutableArtifact? artifact;

  /// Whether no package errors were reported.
  bool get isValid => artifact != null && !diagnostics.hasErrors;
}
