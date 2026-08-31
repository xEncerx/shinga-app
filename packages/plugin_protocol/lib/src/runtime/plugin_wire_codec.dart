import 'package:plugin_protocol/src/runtime/runtime.dart';

/// Strict codec and exact-version dispatcher for public wire envelopes.
abstract final class PluginWireCodec {
  /// Decodes a protocol-v1 invocation request and rejects unknown fields.
  static PluginInvocationRequestV1 decodeInvocationRequest(Object? value) {
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

  /// Decodes a protocol-v1 invocation response with exact outcome cardinality.
  static PluginInvocationResponseV1 decodeInvocationResponse(Object? value) {
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

  /// Decodes a protocol-v1 host-call request and rejects unknown fields.
  static PluginHostCallRequestV1 decodeHostCallRequest(Object? value) {
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

  /// Decodes a protocol-v1 host-call response with exact outcome cardinality.
  static PluginHostCallResponseV1 decodeHostCallResponse(Object? value) {
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
  if (map['version'] != PluginProtocolLimits.protocolVersion) {
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
