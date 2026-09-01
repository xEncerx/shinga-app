import 'package:plugin_protocol/src/runtime/bounded_json_codec.dart';
import 'package:plugin_protocol/src/runtime/internal/protocol_validation.dart';
import 'package:plugin_protocol/src/runtime/plugin_error.dart';
import 'package:plugin_protocol/src/runtime/plugin_host_call.dart';
import 'package:plugin_protocol/src/runtime/plugin_invocation.dart';
import 'package:plugin_protocol/src/runtime/plugin_protocol_limits.dart';
import 'package:plugin_protocol/src/runtime/plugin_wire_contracts.dart';
import 'package:plugin_protocol/src/runtime/plugin_wire_protocol.dart';

/// The frozen codec for internal wire protocol version 1.
final class PluginWireProtocolV1 implements PluginWireProtocol {
  /// Creates the stateless wire-v1 codec.
  const PluginWireProtocolV1();

  /// The literal version permanently owned by this codec.
  static const int wireVersion = 1;

  @override
  int get version => wireVersion;

  @override
  PluginInvocationRequestV1 decodeInvocationRequest(Object? value) {
    final map = _envelope(
      value,
      'invocation.not_object',
      PluginProtocolLimits.maxInputBytes,
    );
    _expectFields(map, const {
      'version',
      'invocationId',
      'pluginId',
      'pluginVersion',
      'pluginApiVersion',
      'method',
      'params',
    });
    _version(map);
    return PluginInvocationRequestV1(
      invocationId: _string(map, 'invocationId'),
      pluginId: _string(map, 'pluginId'),
      pluginVersion: _string(map, 'pluginVersion'),
      pluginApiVersion: _integer(map, 'pluginApiVersion'),
      method: _string(map, 'method'),
      params: map['params'],
    );
  }

  @override
  Map<String, Object?> encodeInvocationRequest(PluginInvocationRequest request) {
    return PluginInvocationRequestV1(
      invocationId: request.invocationId,
      pluginId: request.pluginId,
      pluginVersion: request.pluginVersion,
      pluginApiVersion: request.pluginApiVersion,
      method: request.method,
      params: request.params,
    ).toJson();
  }

  @override
  PluginInvocationResponseV1 decodeInvocationResponse(Object? value) {
    final map = _envelope(
      value,
      'invocation_response.not_object',
      PluginProtocolLimits.maxOutputBytes,
    );
    _version(map);
    _expectOutcomeFields(map);
    if (map.containsKey('result')) {
      return PluginInvocationResponseV1.success(map['result']);
    }
    return PluginInvocationResponseV1.failure(_error(map['error']));
  }

  @override
  Map<String, Object?> encodeInvocationResponse(PluginInvocationResponse response) {
    return response.error == null
        ? PluginInvocationResponseV1.success(response.result).toJson()
        : PluginInvocationResponseV1.failure(response.error!).toJson();
  }

  @override
  PluginHostCallRequestV1 decodeHostCallRequest(Object? value) {
    final map = _envelope(
      value,
      'host_call.not_object',
      PluginProtocolLimits.maxHostCallBytes,
    );
    _expectFields(map, const {
      'version',
      'invocationId',
      'callId',
      'pluginId',
      'pluginApiVersion',
      'operation',
      'deadlineEpochMilliseconds',
      'payload',
    });
    _version(map);
    return PluginHostCallRequestV1(
      invocationId: _string(map, 'invocationId'),
      callId: _string(map, 'callId'),
      pluginId: _string(map, 'pluginId'),
      pluginApiVersion: _integer(map, 'pluginApiVersion'),
      operation: _string(map, 'operation'),
      deadlineEpochMilliseconds: _integer(map, 'deadlineEpochMilliseconds'),
      payload: map['payload'],
    );
  }

  @override
  Map<String, Object?> encodeHostCallRequest(PluginHostCallRequest request) {
    return PluginHostCallRequestV1(
      invocationId: request.invocationId,
      callId: request.callId,
      pluginId: request.pluginId,
      pluginApiVersion: request.pluginApiVersion,
      operation: request.operation,
      deadlineEpochMilliseconds: request.deadlineEpochMilliseconds,
      payload: request.payload,
    ).toJson();
  }

  @override
  PluginHostCallResponseV1 decodeHostCallResponse(Object? value) {
    final map = _envelope(
      value,
      'host_call_response.not_object',
      PluginProtocolLimits.maxHostCallBytes,
    );
    _version(map);
    _expectOutcomeFields(map, metadataFields: const {'callId'});
    final callId = _string(map, 'callId');
    if (map.containsKey('result')) {
      return PluginHostCallResponseV1.success(
        callId: callId,
        result: map['result'],
      );
    }
    return PluginHostCallResponseV1.failure(
      callId: callId,
      error: _error(map['error']),
    );
  }

  @override
  Map<String, Object?> encodeHostCallResponse(PluginHostCallResponse response) {
    return response.error == null
        ? PluginHostCallResponseV1.success(
            callId: response.callId,
            result: response.result,
          ).toJson()
        : PluginHostCallResponseV1.failure(
            callId: response.callId,
            error: response.error!,
          ).toJson();
  }

  @override
  PluginHostCallRequestV1 createHostCallRequest({
    required String invocationId,
    required String callId,
    required String pluginId,
    required int pluginApiVersion,
    required String operation,
    required int deadlineEpochMilliseconds,
    required Object? payload,
  }) {
    return PluginHostCallRequestV1(
      invocationId: invocationId,
      callId: callId,
      pluginId: pluginId,
      pluginApiVersion: pluginApiVersion,
      operation: operation,
      deadlineEpochMilliseconds: deadlineEpochMilliseconds,
      payload: payload,
    );
  }

  @override
  PluginInvocationResponseV1 createInvocationFailure(PluginError error) {
    return PluginInvocationResponseV1.failure(error);
  }

  @override
  PluginHostCallResponseV1 createHostCallFailure({
    required String callId,
    required PluginError error,
  }) {
    return PluginHostCallResponseV1.failure(callId: callId, error: error);
  }
}

/// Backward-compatible static facade for the frozen wire-v1 codec.
abstract final class PluginWireCodec {
  static const _codec = PluginWireProtocolV1();

  /// Decodes a protocol-v1 invocation request.
  static PluginInvocationRequestV1 decodeInvocationRequest(Object? value) {
    return _codec.decodeInvocationRequest(value);
  }

  /// Decodes a protocol-v1 invocation response.
  static PluginInvocationResponseV1 decodeInvocationResponse(Object? value) {
    return _codec.decodeInvocationResponse(value);
  }

  /// Decodes a protocol-v1 host-call request.
  static PluginHostCallRequestV1 decodeHostCallRequest(Object? value) {
    return _codec.decodeHostCallRequest(value);
  }

  /// Decodes a protocol-v1 host-call response.
  static PluginHostCallResponseV1 decodeHostCallResponse(Object? value) {
    return _codec.decodeHostCallResponse(value);
  }
}

Map<String, Object?> _object(Object? value, String code) {
  if (value is! Map<Object?, Object?>) throw PluginProtocolException(code);
  final result = <String, Object?>{};
  for (final entry in value.entries) {
    if (entry.key is! String) {
      throw const PluginProtocolException('envelope.key_not_string');
    }
    result[entry.key! as String] = entry.value;
  }
  return result;
}

Map<String, Object?> _envelope(Object? value, String code, int maxBytes) {
  final copy = BoundedJsonCodec(
    maxBytes: maxBytes,
    hardMaxBytes: maxBytes,
  ).validateAndCopy(value);
  if (copy is! Map<String, Object?>) throw PluginProtocolException(code);
  return copy;
}

void _expectFields(Map<String, Object?> map, Set<String> expected) {
  if (map.length != expected.length || !map.keys.every(expected.contains)) {
    throw const PluginProtocolException('envelope.fields.invalid');
  }
}

void _expectOutcomeFields(
  Map<String, Object?> map, {
  Set<String> metadataFields = const {},
}) {
  final hasResult = map.containsKey('result');
  final hasError = map.containsKey('error');
  final expectedLength = 2 + metadataFields.length;
  if (map.length != expectedLength ||
      hasResult == hasError ||
      !metadataFields.every(map.containsKey)) {
    throw const PluginProtocolException('envelope.outcome.invalid');
  }
}

void _version(Map<String, Object?> map) {
  if (map['version'] != PluginWireProtocolV1.wireVersion) {
    throw const PluginProtocolException('envelope.version.unsupported');
  }
}

int _integer(Map<String, Object?> map, String field) {
  final value = map[field];
  if (value is! int) throw const PluginProtocolException('envelope.field.type');
  return value;
}

String _string(Map<String, Object?> map, String field) {
  final value = map[field];
  if (value is! String) throw const PluginProtocolException('envelope.field.type');
  return value;
}

PluginError _error(Object? value) {
  final map = _object(value, 'error.not_object');
  _expectFields(map, const {'category', 'code'});
  final categoryName = _string(map, 'category');
  final category = PluginErrorCategory.values
      .where((item) => item.name == categoryName)
      .firstOrNull;
  if (category == null) throw const PluginProtocolException('error.category.invalid');
  final code = _string(map, 'code');
  validateIdentifier(code, 'error.code.invalid');
  return PluginError(category: category, code: code);
}
