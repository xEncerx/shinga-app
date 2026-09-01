part of 'inspection.dart';

/// Runs the complete non-executing plugin package inspection pipeline.
final class PluginPackageInspector {
  /// Creates an inspector from independent pipeline stages.
  const PluginPackageInspector({
    required this.manifestLoader,
    required this.packageValidator,
    required this.compatibilityPolicy,
    required this.adapterRegistry,
  });

  /// The bounded manifest loading stage.
  final PluginManifestLoader manifestLoader;

  /// The package entry validation stage.
  final PluginPackageValidator packageValidator;

  /// The manifest and Plugin API compatibility stage.
  final PluginCompatibilityPolicy compatibilityPolicy;

  /// The single extension and artifact-identity dispatch registry.
  final PluginRuntimeAdapterRegistry adapterRegistry;

  /// Inspects [package] without executing plugin code.
  Future<PluginPackageInspection> inspect(PluginPackageReader package) async {
    final loaded = await manifestLoader.load(package);
    final diagnostics = <PluginDiagnostic>[...loaded.diagnostics];
    final manifest = loaded.manifest;
    if (manifest == null || loaded.hasErrors) {
      return InvalidPluginPackage(diagnostics: diagnostics);
    }

    final compatibility = compatibilityPolicy.validate(manifest);
    diagnostics.addAll(compatibility.diagnostics);
    if (!compatibility.isCompatible) {
      return InvalidPluginPackage(diagnostics: diagnostics);
    }
    final apiAdapter = compatibilityPolicy.apiRegistry.adapterForVersion(
      manifest.pluginApiVersion.value,
    )!;
    final adapter = adapterRegistry.adapterForEntry(manifest.entry);
    final PackageValidationResult packageValidation;
    if (adapter == null) {
      final extension = adapterRegistry.extensionOf(manifest.entry);
      diagnostics.add(
        PackageDiagnostic.error(
          code: 'plugin.entry.adapter_unsupported',
          message: extension.isEmpty
              ? 'Entry path has no supported extension.'
              : 'Entry extension "$extension" is not supported.',
          relativePath: manifest.entry.value,
          manifestPath: const JsonPath.root().field('entry'),
        ),
      );
      packageValidation = PackageValidationResult(diagnostics: const []);
    } else {
      packageValidation = await packageValidator.validate(
        package,
        manifest,
        adapter,
        wireProtocolVersion: apiAdapter.wireProtocolVersion,
      );
      diagnostics.addAll(packageValidation.diagnostics);
    }

    final artifact = packageValidation.artifact;
    if (diagnostics.hasErrors || artifact == null) {
      return InvalidPluginPackage(diagnostics: diagnostics);
    }
    return ValidPluginPackage._(
      manifest: manifest,
      artifact: artifact,
      diagnostics: diagnostics,
    );
  }
}
