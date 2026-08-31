part of 'inspection.dart';

/// The result of statically inspecting a plugin package.
sealed class PluginPackageInspection {
  PluginPackageInspection({required List<PluginDiagnostic> diagnostics})
    : diagnostics = List.unmodifiable(diagnostics);

  /// All diagnostics in pipeline reporting order.
  final List<PluginDiagnostic> diagnostics;
}

/// A package that passed manifest, content, and compatibility validation.
final class ValidPluginPackage extends PluginPackageInspection {
  /// Creates a valid package inspection.
  ValidPluginPackage._({
    required this.manifest,
    required this.artifact,
    required super.diagnostics,
  });

  /// The normalized manifest that can proceed to installation policy.
  final PluginManifest manifest;

  /// The exact immutable source artifact approved by inspection.
  final PluginExecutableArtifact artifact;
}

/// A package rejected by at least one inspection stage.
final class InvalidPluginPackage extends PluginPackageInspection {
  /// Creates an invalid package inspection.
  InvalidPluginPackage({required super.diagnostics});
}
