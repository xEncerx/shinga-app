part of 'inspection.dart';

/// Runs the complete non-executing plugin package inspection pipeline.
final class PluginPackageInspector {
  /// Creates an inspector from independent pipeline stages.
  const PluginPackageInspector({
    required this.manifestLoader,
    required this.packageValidator,
    required this.compatibilityPolicy,
  });

  /// The bounded manifest loading stage.
  final PluginManifestLoader manifestLoader;

  /// The package entry validation stage.
  final PluginPackageValidator packageValidator;

  /// The manifest and Plugin API compatibility stage.
  final PluginCompatibilityPolicy compatibilityPolicy;

  /// Inspects [package] without executing interpreted Dart.
  Future<PluginPackageInspection> inspect(PluginPackageReader package) async {
    final loaded = await manifestLoader.load(package);
    final diagnostics = <PluginDiagnostic>[...loaded.diagnostics];
    final manifest = loaded.manifest;
    if (manifest == null || loaded.hasErrors) {
      return InvalidPluginPackage(diagnostics: diagnostics);
    }

    final packageValidation = await packageValidator.validate(package, manifest);
    diagnostics.addAll(packageValidation.diagnostics);
    final compatibility = compatibilityPolicy.validate(manifest);
    diagnostics.addAll(compatibility.diagnostics);

    if (diagnostics.hasErrors) {
      return InvalidPluginPackage(diagnostics: diagnostics);
    }
    return ValidPluginPackage._(
      manifest: manifest,
      artifact: packageValidation.artifact!,
      diagnostics: diagnostics,
    );
  }
}
