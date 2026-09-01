import 'dart:typed_data';

import 'package:plugin_protocol/plugin_protocol.dart';
import 'package:plugin_runtime/src/execution/plugin_runtime_adapter.dart';
import 'package:plugin_runtime/src/package/reader/reader.dart';
import 'package:plugin_runtime/src/package/validation/package_validation_result.dart';

part '../package/validation/plugin_package_validator.dart';

/// Non-executable source input returned by a runtime adapter after preflight.
final class PluginArtifactCandidate {
  /// Creates a candidate from defensive copies of package-relative source bytes.
  PluginArtifactCandidate({required Map<String, Uint8List> sourceBytes})
    : _sourceBytes = _copySourceMap(sourceBytes);

  final Map<String, Uint8List> _sourceBytes;

  /// Returns defensive copies of the exact source bytes offered for validation.
  Map<String, Uint8List> copySourceBytes() => _copySourceMap(_sourceBytes);
}

/// Immutable inspected plugin input bound to one registered runtime adapter.
final class PluginExecutableArtifact {
  PluginExecutableArtifact._({
    required this.pluginId,
    required this.pluginVersion,
    required this.pluginApiVersion,
    required this.wireProtocolVersion,
    required this.entryPath,
    required this.adapterId,
    required Map<String, Uint8List> sourceBytes,
  }) : _sourceBytes = _copySourceMap(sourceBytes);

  /// The manifest plugin identity bound to these exact bytes.
  final String pluginId;

  /// The manifest plugin version bound to these exact bytes.
  final String pluginVersion;

  /// The exact Plugin API version bound to this artifact.
  final int pluginApiVersion;

  /// The exact internal transport selected by the Plugin API adapter.
  final int wireProtocolVersion;

  /// The manifest entry path bound to this artifact and its source bytes.
  final String entryPath;

  /// The registry identity of the adapter selected during inspection.
  final String adapterId;

  final Map<String, Uint8List> _sourceBytes;

  /// Returns defensive copies of the exact inspected source bytes.
  Map<String, Uint8List> copySourceBytes() => _copySourceMap(_sourceBytes);
}

/// The result of adapter-owned source preflight.
final class PluginArtifactBuildResult {
  /// Creates a result from immutable diagnostics and an optional [candidate].
  PluginArtifactBuildResult({
    required List<PackageDiagnostic> diagnostics,
    required this.candidate,
  }) : diagnostics = List.unmodifiable(diagnostics);

  /// Safe structural diagnostics in deterministic traversal order.
  final List<PackageDiagnostic> diagnostics;

  /// The non-executable source candidate when preflight completed without errors.
  final PluginArtifactCandidate? candidate;

  /// Whether a source candidate was produced without errors.
  bool get isValid => candidate != null && !diagnostics.hasErrors;
}

PluginExecutableArtifact _mintPluginExecutableArtifact({
  required PluginManifest manifest,
  required String adapterId,
  required int wireProtocolVersion,
  required Map<String, Uint8List> sourceBytes,
}) {
  return PluginExecutableArtifact._(
    pluginId: manifest.id.value,
    pluginVersion: manifest.version.value,
    pluginApiVersion: manifest.pluginApiVersion.value,
    wireProtocolVersion: wireProtocolVersion,
    entryPath: manifest.entry.value,
    adapterId: adapterId,
    sourceBytes: sourceBytes,
  );
}

Map<String, Uint8List> _copySourceMap(Map<String, Uint8List> source) {
  return Map.unmodifiable({
    for (final entry in source.entries) entry.key: Uint8List.fromList(entry.value),
  });
}
