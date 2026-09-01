import 'package:plugin_protocol/plugin_protocol.dart';
import 'package:plugin_runtime/src/api/plugin_api_registry.dart';
import 'package:plugin_runtime/src/compatibility/compatibility_result.dart';

/// Validates manifest and Plugin API versions against runtime support.
final class PluginCompatibilityPolicy {
  /// Creates a compatibility policy from schema and compiled API registries.
  PluginCompatibilityPolicy({
    required this.parser,
    required this.apiRegistry,
  });

  /// The parser whose manifest schema support is used by this runtime.
  final PluginManifestParser parser;

  /// The sole source of exact Plugin API support.
  final PluginApiRegistry apiRegistry;

  /// The exact Plugin API versions derived from [apiRegistry].
  Set<int> get supportedPluginApiVersions => apiRegistry.supportedVersions;

  /// Validates the two independent version declarations in [manifest].
  CompatibilityResult validate(PluginManifest manifest) {
    final diagnostics = <PackageDiagnostic>[];
    if (!parser.supportedManifestVersions.contains(manifest.manifestVersion.value)) {
      diagnostics.add(
        PackageDiagnostic(
          code: 'plugin.compatibility.manifest_version_unsupported',
          severity: DiagnosticSeverity.error,
          message:
              'Manifest version ${manifest.manifestVersion.value} is not supported by this runtime.',
          manifestPath: const JsonPath.root().field('manifestVersion'),
        ),
      );
    }
    if (apiRegistry.adapterForVersion(manifest.pluginApiVersion.value) == null) {
      diagnostics.add(
        PackageDiagnostic(
          code: 'plugin.compatibility.api_version_unsupported',
          severity: DiagnosticSeverity.error,
          message:
              'Plugin API version ${manifest.pluginApiVersion.value} is not supported by this runtime.',
          manifestPath: const JsonPath.root().field('pluginApiVersion'),
        ),
      );
    }
    return CompatibilityResult(diagnostics: diagnostics);
  }
}
