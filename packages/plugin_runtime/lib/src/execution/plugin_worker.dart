import 'dart:async';

import 'package:plugin_protocol/plugin_protocol.dart';

/// Language-independent services available inside one plugin worker.
final class PluginWorkerContext {
  /// Creates the context supplied to a registered adapter entrypoint.
  const PluginWorkerContext({
    required this.request,
    required this.deadlineEpochMilliseconds,
    required this.deadlineEpochMicroseconds,
    required this.hostCalls,
  });

  /// The bounded invocation request decoded by the shared worker runtime.
  final PluginInvocationRequest request;

  /// The absolute invocation deadline included in host-call envelopes.
  final int deadlineEpochMilliseconds;

  /// The higher-resolution absolute deadline available to adapter controls.
  final int deadlineEpochMicroseconds;

  /// The correlated, bounded host-call channel for this invocation.
  final PluginWorkerHostCalls hostCalls;
}

/// Correlated host-call access owned by the shared worker runtime.
abstract interface class PluginWorkerHostCalls {
  /// Starts one bounded operation and resolves its matching response envelope.
  Future<PluginHostCallResponse> call(String operation, Object? payload);

  /// Encodes a response for the selected internal worker transport.
  Map<String, Object?> encodeResponse(PluginHostCallResponse response);
}
