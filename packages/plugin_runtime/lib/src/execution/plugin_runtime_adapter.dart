import 'dart:async';

import 'package:plugin_protocol/plugin_protocol.dart';
import 'package:plugin_runtime/src/execution/plugin_executable_artifact.dart';
import 'package:plugin_runtime/src/execution/plugin_worker.dart';
import 'package:plugin_runtime/src/package/reader/plugin_package_reader.dart';

/// Language adapter registered with the shared plugin runtime.
abstract interface class PluginRuntimeAdapter {
  /// Stable identity persisted in inspected artifacts.
  String get id;

  /// Exact case-sensitive entry extensions handled by this adapter.
  Set<String> get entryExtensions;

  /// Performs language-specific source preflight without executing plugin code.
  Future<PluginArtifactBuildResult> inspect(
    PluginPackageReader package,
    PluginManifest manifest,
  );

  /// Derives the sendable worker payload from an execution-authorized artifact.
  Object? createWorkerPayload(PluginExecutableArtifact artifact);

  /// Runs adapter-specific behavior inside a runtime-created worker.
  PluginWorkerEntrypoint get workerEntrypoint;
}

/// Adapter behavior invoked inside the runtime-owned worker isolate.
typedef PluginWorkerEntrypoint =
    FutureOr<PluginInvocationResponseV1> Function(
      PluginWorkerContext context,
      Object? adapterPayload,
    );
