import 'package:meta/meta.dart';
import 'package:plugin_protocol/src/runtime/runtime.dart';

/// A protocol-v1 request to execute one inspected plugin method.
@immutable
final class PluginInvocationRequestV1 {
  /// Creates and validates an invocation request.
  factory PluginInvocationRequestV1({
    required String invocationId,
    required String pluginId,
    required String pluginVersion,
    required int pluginApiVersion,
    required String method,
    required Object? params,
  }) {
    validateIdentifier(invocationId, 'invocation.id.invalid');
    validateIdentifier(pluginId, 'invocation.plugin_id.invalid', maxBytes: 253);
    validateIdentifier(pluginVersion, 'invocation.plugin_version.invalid');
    validateIdentifier(method, 'invocation.method.invalid');
    if (!RegExp(r'^[A-Za-z_$][A-Za-z0-9_$]*$').hasMatch(method)) {
      throw const PluginProtocolException('invocation.method.invalid');
    }
    if (pluginApiVersion != PluginProtocolLimits.pluginApiVersion) {
      throw const PluginProtocolException('invocation.api_version.unsupported');
    }
    final envelope =
        const BoundedJsonCodec(
              maxBytes: PluginProtocolLimits.maxInputBytes,
              hardMaxBytes: PluginProtocolLimits.maxInputBytes,
            ).validateAndCopy(<String, Object?>{
              'version': PluginProtocolLimits.protocolVersion,
              'invocationId': invocationId,
              'pluginId': pluginId,
              'pluginVersion': pluginVersion,
              'pluginApiVersion': pluginApiVersion,
              'method': method,
              'params': params,
            })!
            as Map<String, Object?>;
    return PluginInvocationRequestV1._(
      invocationId: invocationId,
      pluginId: pluginId,
      pluginVersion: pluginVersion,
      pluginApiVersion: pluginApiVersion,
      method: method,
      params: envelope['params'],
    );
  }

  const PluginInvocationRequestV1._({
    required this.invocationId,
    required this.pluginId,
    required this.pluginVersion,
    required this.pluginApiVersion,
    required this.method,
    required this.params,
  });

  /// The caller-generated correlation identifier.
  final String invocationId;

  /// The inspected plugin identity.
  final String pluginId;

  /// The inspected plugin package version.
  final String pluginVersion;

  /// The exact dispatched Plugin API version.
  final int pluginApiVersion;

  /// The top-level interpreted function to execute.
  final String method;

  /// The deeply immutable bounded input value.
  final Object? params;

  /// Encodes this request as the versioned JSON envelope.
  Map<String, Object?> toJson() => <String, Object?>{
    'version': PluginProtocolLimits.protocolVersion,
    'invocationId': invocationId,
    'pluginId': pluginId,
    'pluginVersion': pluginVersion,
    'pluginApiVersion': pluginApiVersion,
    'method': method,
    'params': params,
  };
}

/// A protocol-v1 invocation response containing exactly one terminal outcome.
@immutable
final class PluginInvocationResponseV1 {
  const PluginInvocationResponseV1._({this.result, this.error});

  /// Creates a successful response from a bounded immutable [result].
  factory PluginInvocationResponseV1.success(Object? result) {
    final envelope =
        const BoundedJsonCodec(
              maxBytes: PluginProtocolLimits.maxOutputBytes,
              hardMaxBytes: PluginProtocolLimits.maxOutputBytes,
            ).validateAndCopy(<String, Object?>{
              'version': PluginProtocolLimits.protocolVersion,
              'result': result,
            })!
            as Map<String, Object?>;
    return PluginInvocationResponseV1._(result: envelope['result']);
  }

  /// Creates a failed response containing only a safe [error].
  factory PluginInvocationResponseV1.failure(PluginError error) {
    const BoundedJsonCodec(
      maxBytes: PluginProtocolLimits.maxOutputBytes,
      hardMaxBytes: PluginProtocolLimits.maxOutputBytes,
    ).validateAndCopy(<String, Object?>{
      'version': PluginProtocolLimits.protocolVersion,
      'error': error.toJson(),
    });
    return PluginInvocationResponseV1._(error: error);
  }

  /// The bounded result when [isSuccess] is true.
  final Object? result;

  /// The safe error when [isSuccess] is false.
  final PluginError? error;

  /// Whether this response is successful, including a successful `null` result.
  bool get isSuccess => error == null;

  /// Encodes this response without a result/error collision.
  Map<String, Object?> toJson() => <String, Object?>{
    'version': PluginProtocolLimits.protocolVersion,
    if (error == null) 'result': result else 'error': error!.toJson(),
  };
}
