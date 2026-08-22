import 'package:meta/meta.dart';
import 'package:plugin_protocol/src/common/diagnostics/diagnostics.dart';
import 'package:plugin_protocol/src/manifest/models/plugin_manifest.dart';

/// The normalized manifest and diagnostics produced by parsing source text.
@immutable
final class ManifestParseResult {
  /// Creates a parse result from a defensive copy of [diagnostics].
  ManifestParseResult({
    required this.manifest,
    required List<ManifestDiagnostic> diagnostics,
  }) : diagnostics = List.unmodifiable(diagnostics);

  /// The parsed manifest, or `null` when parsing failed.
  final PluginManifest? manifest;

  /// All diagnostics in reporting order.
  final List<ManifestDiagnostic> diagnostics;

  /// Whether at least one error was reported.
  bool get hasErrors => diagnostics.hasErrors;

  /// Whether a manifest was produced without errors.
  bool get isSuccess => manifest != null && !hasErrors;
}
