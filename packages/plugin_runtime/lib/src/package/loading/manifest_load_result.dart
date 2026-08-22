import 'package:plugin_protocol/plugin_protocol.dart';

/// The manifest and diagnostics produced while loading a plugin package.
final class ManifestLoadResult {
  /// Creates a manifest load result from a defensive copy of [diagnostics].
  ManifestLoadResult({
    required this.manifest,
    required List<PluginDiagnostic> diagnostics,
  }) : diagnostics = List.unmodifiable(diagnostics);

  /// The parsed manifest, or `null` when loading failed.
  final PluginManifest? manifest;

  /// All package and manifest diagnostics in reporting order.
  final List<PluginDiagnostic> diagnostics;

  /// Whether at least one error was reported.
  bool get hasErrors => diagnostics.hasErrors;

  /// Whether a manifest was produced without errors.
  bool get isSuccess => manifest != null && !hasErrors;
}
