import 'package:meta/meta.dart';
import 'package:plugin_protocol/src/runtime/runtime.dart';

/// A correlated protocol-v1 request for one generic host operation.
@immutable
final class PluginHostCallRequestV1 {
  /// Creates and validates a child call that inherits its parent identity.
  factory PluginHostCallRequestV1({
    required String invocationId,
    required String callId,
    required String pluginId,
    required int pluginApiVersion,
    required String operation,
    required int deadlineEpochMilliseconds,
    required Object? payload,
  }) {
    validateIdentifier(invocationId, 'host_call.invocation_id.invalid');
    validateIdentifier(callId, 'host_call.call_id.invalid');
    validateIdentifier(pluginId, 'host_call.plugin_id.invalid', maxBytes: 253);
    validateIdentifier(operation, 'host_call.operation.invalid');
    if (pluginApiVersion != PluginProtocolLimits.pluginApiVersion) {
      throw const PluginProtocolException('host_call.api_version.unsupported');
    }
    if (deadlineEpochMilliseconds <= 0 || deadlineEpochMilliseconds > 9007199254740991) {
      throw const PluginProtocolException('host_call.deadline.invalid');
    }
    final envelope =
        const BoundedJsonCodec(
              maxBytes: PluginProtocolLimits.maxHostCallBytes,
              hardMaxBytes: PluginProtocolLimits.maxHostCallBytes,
            ).validateAndCopy(<String, Object?>{
              'version': PluginProtocolLimits.protocolVersion,
              'invocationId': invocationId,
              'callId': callId,
              'pluginId': pluginId,
              'pluginApiVersion': pluginApiVersion,
              'operation': operation,
              'deadlineEpochMilliseconds': deadlineEpochMilliseconds,
              'payload': payload,
            })!
            as Map<String, Object?>;
    return PluginHostCallRequestV1._(
      invocationId: invocationId,
      callId: callId,
      pluginId: pluginId,
      pluginApiVersion: pluginApiVersion,
      operation: operation,
      deadlineEpochMilliseconds: deadlineEpochMilliseconds,
      payload: envelope['payload'],
    );
  }

  const PluginHostCallRequestV1._({
    required this.invocationId,
    required this.callId,
    required this.pluginId,
    required this.pluginApiVersion,
    required this.operation,
    required this.deadlineEpochMilliseconds,
    required this.payload,
  });

  /// The inherited invocation identifier.
  final String invocationId;

  /// The unique call identifier within one invocation.
  final String callId;

  /// The inherited plugin identity.
  final String pluginId;

  /// The inherited exact Plugin API version.
  final int pluginApiVersion;

  /// The generic host operation name.
  final String operation;

  /// The inherited absolute invocation deadline.
  final int deadlineEpochMilliseconds;

  /// The deeply immutable bounded operation payload.
  final Object? payload;

  /// Encodes this child request as the versioned JSON envelope.
  Map<String, Object?> toJson() => <String, Object?>{
    'version': PluginProtocolLimits.protocolVersion,
    'invocationId': invocationId,
    'callId': callId,
    'pluginId': pluginId,
    'pluginApiVersion': pluginApiVersion,
    'operation': operation,
    'deadlineEpochMilliseconds': deadlineEpochMilliseconds,
    'payload': payload,
  };
}

/// A protocol-v1 host-call response containing exactly one outcome.
@immutable
final class PluginHostCallResponseV1 {
  const PluginHostCallResponseV1._({required this.callId, this.result, this.error});

  /// Creates a successful bounded host-call response.
  factory PluginHostCallResponseV1.success({required String callId, required Object? result}) {
    validateIdentifier(callId, 'host_call_response.call_id.invalid');
    final envelope =
        const BoundedJsonCodec(
              maxBytes: PluginProtocolLimits.maxHostCallBytes,
              hardMaxBytes: PluginProtocolLimits.maxHostCallBytes,
            ).validateAndCopy(<String, Object?>{
              'version': PluginProtocolLimits.protocolVersion,
              'callId': callId,
              'result': result,
            })!
            as Map<String, Object?>;
    return PluginHostCallResponseV1._(
      callId: callId,
      result: envelope['result'],
    );
  }

  /// Creates a structured host-call rejection.
  factory PluginHostCallResponseV1.failure({
    required String callId,
    required PluginError error,
  }) {
    validateIdentifier(callId, 'host_call_response.call_id.invalid');
    const BoundedJsonCodec(
      maxBytes: PluginProtocolLimits.maxHostCallBytes,
      hardMaxBytes: PluginProtocolLimits.maxHostCallBytes,
    ).validateAndCopy(<String, Object?>{
      'version': PluginProtocolLimits.protocolVersion,
      'callId': callId,
      'error': error.toJson(),
    });
    return PluginHostCallResponseV1._(callId: callId, error: error);
  }

  /// The inherited request identifier owned by this response envelope.
  final String callId;

  /// The result when [isSuccess] is true.
  final Object? result;

  /// The safe rejection when [isSuccess] is false.
  final PluginError? error;

  /// Whether this response is successful, including a successful `null` result.
  bool get isSuccess => error == null;

  /// Encodes this response without a result/error collision.
  Map<String, Object?> toJson() => <String, Object?>{
    'version': PluginProtocolLimits.protocolVersion,
    'callId': callId,
    if (error == null) 'result': result else 'error': error!.toJson(),
  };
}
