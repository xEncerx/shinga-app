import 'package:meta/meta.dart';
import 'package:plugin_protocol/src/runtime/bounded_json_codec.dart';
import 'package:plugin_protocol/src/runtime/internal/protocol_validation.dart';
import 'package:plugin_protocol/src/runtime/plugin_error.dart';
import 'package:plugin_protocol/src/runtime/plugin_protocol_limits.dart';
import 'package:plugin_protocol/src/runtime/plugin_wire_contracts.dart';

/// A correlated protocol-v1 request for one generic host operation.
@immutable
final class PluginHostCallRequestV1 implements PluginHostCallRequest {
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
    if (pluginApiVersion <= 0 || pluginApiVersion > 9007199254740991) {
      throw const PluginProtocolException('host_call.api_version.invalid');
    }
    if (deadlineEpochMilliseconds <= 0 || deadlineEpochMilliseconds > 9007199254740991) {
      throw const PluginProtocolException('host_call.deadline.invalid');
    }
    final envelope =
        const BoundedJsonCodec(
              maxBytes: PluginProtocolLimits.maxHostCallBytes,
              hardMaxBytes: PluginProtocolLimits.maxHostCallBytes,
            ).validateAndCopy(<String, Object?>{
              'version': wireVersion,
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

  /// The literal wire version permanently owned by this DTO.
  static const int wireVersion = 1;

  /// The inherited invocation identifier.
  @override
  final String invocationId;

  /// The unique call identifier within one invocation.
  @override
  final String callId;

  /// The inherited plugin identity.
  @override
  final String pluginId;

  /// The inherited exact Plugin API version.
  @override
  final int pluginApiVersion;

  /// The generic host operation name.
  @override
  final String operation;

  /// The inherited absolute invocation deadline.
  @override
  final int deadlineEpochMilliseconds;

  /// The deeply immutable bounded operation payload.
  @override
  final Object? payload;

  /// Encodes this child request as the versioned JSON envelope.
  Map<String, Object?> toJson() => <String, Object?>{
    'version': wireVersion,
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
final class PluginHostCallResponseV1 implements PluginHostCallResponse {
  const PluginHostCallResponseV1._({required this.callId, this.result, this.error});

  /// Creates a successful bounded host-call response.
  factory PluginHostCallResponseV1.success({required String callId, required Object? result}) {
    validateIdentifier(callId, 'host_call_response.call_id.invalid');
    final envelope =
        const BoundedJsonCodec(
              maxBytes: PluginProtocolLimits.maxHostCallBytes,
              hardMaxBytes: PluginProtocolLimits.maxHostCallBytes,
            ).validateAndCopy(<String, Object?>{
              'version': wireVersion,
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
      'version': wireVersion,
      'callId': callId,
      'error': error.toJson(),
    });
    return PluginHostCallResponseV1._(callId: callId, error: error);
  }

  /// The literal wire version permanently owned by this DTO.
  static const int wireVersion = 1;

  /// The inherited request identifier owned by this response envelope.
  @override
  final String callId;

  /// The result when [isSuccess] is true.
  @override
  final Object? result;

  /// The safe rejection when [isSuccess] is false.
  @override
  final PluginError? error;

  /// Whether this response is successful, including a successful `null` result.
  @override
  bool get isSuccess => error == null;

  /// Encodes this response without a result/error collision.
  Map<String, Object?> toJson() => <String, Object?>{
    'version': wireVersion,
    'callId': callId,
    if (error == null) 'result': result else 'error': error!.toJson(),
  };
}
