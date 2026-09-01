import 'package:plugin_protocol/src/runtime/plugin_error.dart';
import 'package:plugin_protocol/src/runtime/plugin_wire_contracts.dart';

/// An immutable codec for one exact internal plugin transport version.
///
/// Implementations are trusted compiled host code and must remain stateless so
/// the same built-in codec can be resolved independently in each isolate.
abstract interface class PluginWireProtocol {
  /// The exact positive wire version implemented by this codec.
  int get version;

  /// Decodes an invocation request for this exact wire version.
  PluginInvocationRequest decodeInvocationRequest(Object? value);

  /// Encodes an invocation request for this exact wire version.
  Map<String, Object?> encodeInvocationRequest(PluginInvocationRequest request);

  /// Decodes a terminal invocation response for this exact wire version.
  PluginInvocationResponse decodeInvocationResponse(Object? value);

  /// Encodes a terminal invocation response for this exact wire version.
  Map<String, Object?> encodeInvocationResponse(PluginInvocationResponse response);

  /// Decodes a host-call request for this exact wire version.
  PluginHostCallRequest decodeHostCallRequest(Object? value);

  /// Encodes a host-call request for this exact wire version.
  Map<String, Object?> encodeHostCallRequest(PluginHostCallRequest request);

  /// Decodes a host-call response for this exact wire version.
  PluginHostCallResponse decodeHostCallResponse(Object? value);

  /// Encodes a host-call response for this exact wire version.
  Map<String, Object?> encodeHostCallResponse(PluginHostCallResponse response);

  /// Creates a validated host-call request owned by this wire version.
  PluginHostCallRequest createHostCallRequest({
    required String invocationId,
    required String callId,
    required String pluginId,
    required int pluginApiVersion,
    required String operation,
    required int deadlineEpochMilliseconds,
    required Object? payload,
  });

  /// Creates a failed invocation response owned by this wire version.
  PluginInvocationResponse createInvocationFailure(PluginError error);

  /// Creates a failed host-call response owned by this wire version.
  PluginHostCallResponse createHostCallFailure({
    required String callId,
    required PluginError error,
  });
}
