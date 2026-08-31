import 'dart:convert';

import 'package:plugin_protocol/plugin_protocol.dart';
import 'package:test/test.dart';

/// Frozen JSON fixtures used to test compatible protocol implementations.
final class _PluginProtocolFixtures {
  /// A canonical invocation request for protocol and Plugin API version 1.
  static const Map<String, Object?> invocationRequestV1 = {
    'version': 1,
    'invocationId': 'invocation-1',
    'pluginId': 'dev.shinga.fixture',
    'pluginVersion': '1.0.0',
    'pluginApiVersion': 1,
    'method': 'echo',
    'params': <String, Object?>{'value': 42},
  };

  /// A canonical correlated host-call request.
  static const Map<String, Object?> hostCallRequestV1 = {
    'version': 1,
    'invocationId': 'invocation-1',
    'callId': 'call-1',
    'pluginId': 'dev.shinga.fixture',
    'pluginApiVersion': 1,
    'operation': 'fixture.sync',
    'deadlineEpochMilliseconds': 2000000000000,
    'payload': <String, Object?>{'value': 21},
  };
}

void main() {
  group('BoundedJsonCodec', () {
    const codec = BoundedJsonCodec(
      maxBytes: PluginProtocolLimits.maxInputBytes,
      hardMaxBytes: PluginProtocolLimits.maxInputBytes,
    );

    test('accepts JSON values and returns immutable defensive copies', () {
      final source = <String, Object?>{
        'values': <Object?>[null, true, 'text', 42, 1.5],
      };

      final result = (codec.validateAndCopy(source) as Map<String, Object?>?)!;
      (source['values'] as List<Object?>?)!.add('late');

      expect(result, {
        'values': [null, true, 'text', 42, 1.5],
      });
      expect(() => result['late'] = true, throwsUnsupportedError);
      expect(() => (result['values']! as List<Object?>).add(true), throwsUnsupportedError);
    });

    test('accepts exact string, collection, depth, node, and byte bounds', () {
      final exactString = 'a' * PluginProtocolLimits.maxStringBytes;
      final exactCollection = List<Object?>.filled(
        PluginProtocolLimits.maxCollectionLength,
        null,
      );
      Object? exactDepth;
      for (var index = 0; index <= PluginProtocolLimits.maxJsonDepth; index += 1) {
        exactDepth = <Object?>[exactDepth];
      }
      final exactNodes = <Object?>[
        ...List<Object?>.generate(999, (_) => List<Object?>.filled(9, null)),
        List<Object?>.filled(8, null),
      ];
      final exactBytesValue = <Object?>[
        'a' * 65535,
        'a' * 65532,
        'a' * 65532,
        'a' * 65532,
      ];

      expect(codec.validateAndCopy(exactString), exactString);
      expect(codec.validateAndCopy(exactCollection), hasLength(exactCollection.length));
      expect(codec.validateAndCopy(exactDepth), isNotNull);
      expect(codec.validateAndCopy(exactNodes), hasLength(exactNodes.length));
      expect(utf8.encode(jsonEncode(codec.validateAndCopy(exactBytesValue))), hasLength(262144));
    });

    test('accepts and rejects exact UTF-8 object-key byte bounds', () {
      final exactKey = 'é' * (PluginProtocolLimits.maxStringBytes ~/ 2);
      final oneOverKey = '${exactKey}a';

      expect(codec.validateAndCopy(<String, Object?>{exactKey: true}), {exactKey: true});
      expect(
        () => codec.validateAndCopy(<String, Object?>{oneOverKey: true}),
        throwsA(_protocolCode('json.string_too_large')),
      );
    });

    test('accepts exact JS-safe integers and rejects both adjacent values', () {
      const maximum = 9007199254740991;
      const minimum = -9007199254740991;

      expect(codec.validateAndCopy(maximum), maximum);
      expect(codec.validateAndCopy(minimum), minimum);
      expect(
        () => codec.validateAndCopy(maximum + 1),
        throwsA(_protocolCode('json.integer_not_js_safe')),
      );
      expect(
        () => codec.validateAndCopy(minimum - 1),
        throwsA(_protocolCode('json.integer_not_js_safe')),
      );
    });

    test('rejects values one beyond every JSON hard ceiling', () {
      Object? tooDeep;
      for (var index = 0; index <= PluginProtocolLimits.maxJsonDepth + 1; index += 1) {
        tooDeep = <Object?>[tooDeep];
      }
      final cases = <(String, Object?)>[
        ('json.string_too_large', 'a' * (PluginProtocolLimits.maxStringBytes + 1)),
        (
          'json.collection_too_large',
          List<Object?>.filled(PluginProtocolLimits.maxCollectionLength + 1, null),
        ),
        ('json.too_deep', tooDeep),
        (
          'json.too_many_nodes',
          <Object?>[
            ...List<Object?>.generate(999, (_) => List<Object?>.filled(9, null)),
            List<Object?>.filled(9, null),
          ],
        ),
        (
          'json.serialized_too_large',
          <Object?>['a' * 65536, 'a' * 65532, 'a' * 65532, 'a' * 65532],
        ),
      ];

      for (final (code, value) in cases) {
        expect(
          () => codec.validateAndCopy(value),
          throwsA(isA<PluginProtocolException>().having((error) => error.code, 'code', code)),
          reason: code,
        );
      }
    });

    test('rejects cycles, non-string keys, unsafe numbers, and unsupported objects', () {
      final cycle = <Object?>[];
      cycle.add(cycle);
      final cases = <(String, Object?)>[
        ('json.cycle', cycle),
        ('json.object_key_not_string', <Object?, Object?>{1: true}),
        ('json.number_not_finite', double.nan),
        ('json.number_not_finite', double.infinity),
        ('json.integer_not_js_safe', 9007199254740992),
        ('json.type_unsupported', DateTime.utc(2026)),
      ];

      for (final (code, value) in cases) {
        expect(
          () => codec.validateAndCopy(value),
          throwsA(isA<PluginProtocolException>().having((error) => error.code, 'code', code)),
          reason: code,
        );
      }
    });
  });

  group('PluginWireCodec', () {
    test('round-trips frozen invocation and host-call request fixtures', () {
      final invocation = PluginWireCodec.decodeInvocationRequest(
        _PluginProtocolFixtures.invocationRequestV1,
      );
      final hostCall = PluginWireCodec.decodeHostCallRequest(
        _PluginProtocolFixtures.hostCallRequestV1,
      );

      expect(invocation.toJson(), _PluginProtocolFixtures.invocationRequestV1);
      expect(hostCall.toJson(), _PluginProtocolFixtures.hostCallRequestV1);
    });

    test('dispatches only exact protocol and Plugin API version 1', () {
      expect(
        () => PluginWireCodec.decodeInvocationRequest({
          ..._PluginProtocolFixtures.invocationRequestV1,
          'version': 2,
        }),
        throwsA(_protocolCode('envelope.version.unsupported')),
      );
      expect(
        () => PluginWireCodec.decodeInvocationRequest({
          ..._PluginProtocolFixtures.invocationRequestV1,
          'pluginApiVersion': 2,
        }),
        throwsA(_protocolCode('invocation.api_version.unsupported')),
      );
    });

    test('rejects response collisions, missing outcomes, and unknown fields', () {
      final invalid = <Object?>[
        {'version': 1, 'result': 1, 'error': null},
        {'version': 1},
        {'version': 1, 'result': 1, 'unknown': true},
      ];

      for (final value in invalid) {
        expect(
          () => PluginWireCodec.decodeInvocationResponse(value),
          throwsA(_protocolCode('envelope.outcome.invalid')),
        );
      }
    });

    test('round-trips all stable safe error categories without internals', () {
      for (final category in PluginErrorCategory.values) {
        final response = PluginInvocationResponseV1.failure(
          PluginError(category: category, code: 'fixture.reason'),
        );

        final decoded = PluginWireCodec.decodeInvocationResponse(response.toJson());

        expect(decoded.error?.category, category);
        expect(decoded.error?.code, 'fixture.reason');
        expect(response.toJson().toString(), isNot(contains('stack')));
      }
    });

    test('validates exact and one-over complete invocation envelopes', () {
      final exactRequestPayload = _multibytePayloadForEnvelope(
        PluginProtocolLimits.maxInputBytes,
        _invocationEnvelope,
      );
      final exactResponseResult = _multibytePayloadForEnvelope(
        PluginProtocolLimits.maxOutputBytes,
        _invocationResponseEnvelope,
      );

      final request = _invocationRequest(exactRequestPayload);
      final response = PluginInvocationResponseV1.success(exactResponseResult);

      expect(_encodedLength(request.toJson()), PluginProtocolLimits.maxInputBytes);
      expect(_encodedLength(response.toJson()), PluginProtocolLimits.maxOutputBytes);
      expect(
        () => _invocationRequest(
          _multibytePayloadForEnvelope(
            PluginProtocolLimits.maxInputBytes + 1,
            _invocationEnvelope,
          ),
        ),
        throwsA(_protocolCode('json.serialized_too_large')),
      );
      expect(
        () => PluginInvocationResponseV1.success(
          _multibytePayloadForEnvelope(
            PluginProtocolLimits.maxOutputBytes + 1,
            _invocationResponseEnvelope,
          ),
        ),
        throwsA(_protocolCode('json.serialized_too_large')),
      );
    });

    test('validates exact and one-over complete host-call envelopes', () {
      final exactRequestPayload = _multibytePayloadForEnvelope(
        PluginProtocolLimits.maxHostCallBytes,
        _hostCallEnvelope,
      );
      final exactResponseResult = _multibytePayloadForEnvelope(
        PluginProtocolLimits.maxHostCallBytes,
        _hostCallResponseEnvelope,
      );

      final request = _hostCallRequest(exactRequestPayload);
      final response = PluginHostCallResponseV1.success(
        callId: 'call-1',
        result: exactResponseResult,
      );

      expect(_encodedLength(request.toJson()), PluginProtocolLimits.maxHostCallBytes);
      expect(_encodedLength(response.toJson()), PluginProtocolLimits.maxHostCallBytes);
      expect(
        () => _hostCallRequest(
          _multibytePayloadForEnvelope(
            PluginProtocolLimits.maxHostCallBytes + 1,
            _hostCallEnvelope,
          ),
        ),
        throwsA(_protocolCode('json.serialized_too_large')),
      );
      expect(
        () => PluginHostCallResponseV1.success(
          callId: 'call-1',
          result: _multibytePayloadForEnvelope(
            PluginProtocolLimits.maxHostCallBytes + 1,
            _hostCallResponseEnvelope,
          ),
        ),
        throwsA(_protocolCode('json.serialized_too_large')),
      );
    });

    test('validates complete failure metadata before encoding', () {
      expect(
        () => PluginError(
          category: PluginErrorCategory.engineFailure,
          code: 'é' * 65,
        ),
        throwsA(_protocolCode('error.code.invalid')),
      );
      expect(
        () => PluginWireCodec.decodeInvocationResponse({
          'version': 1,
          'error': {
            'category': 'engineFailure',
            'code': 'a' * (PluginProtocolLimits.maxIdentifierBytes + 1),
          },
        }),
        throwsA(_protocolCode('error.code.invalid')),
      );
      final exactCallId = 'é' * (PluginProtocolLimits.maxIdentifierBytes ~/ 2);
      final response = PluginHostCallResponseV1.failure(
        callId: exactCallId,
        error: PluginError(
          category: PluginErrorCategory.hostDenied,
          code: exactCallId,
        ),
      );

      expect(response.toJson()['callId'], exactCallId);
      expect(
        () => PluginHostCallResponseV1.failure(
          callId: '${exactCallId}a',
          error: PluginError(
            category: PluginErrorCategory.hostDenied,
            code: 'fixture.denied',
          ),
        ),
        throwsA(_protocolCode('host_call_response.call_id.invalid')),
      );
    });

    test('requires protocol-owned host response correlation metadata', () {
      expect(
        () => PluginWireCodec.decodeHostCallResponse({
          'version': 1,
          'result': true,
        }),
        throwsA(_protocolCode('envelope.outcome.invalid')),
      );

      final decoded = PluginWireCodec.decodeHostCallResponse({
        'version': 1,
        'callId': 'call-1',
        'error': {'category': 'hostDenied', 'code': 'fixture.denied'},
      });

      expect(decoded.callId, 'call-1');
      expect(decoded.error?.code, 'fixture.denied');
    });
  });
}

Matcher _protocolCode(String code) {
  return isA<PluginProtocolException>().having((error) => error.code, 'code', code);
}

PluginInvocationRequestV1 _invocationRequest(Object? params) {
  return PluginInvocationRequestV1(
    invocationId: 'invocation-1',
    pluginId: 'dev.shinga.fixture',
    pluginVersion: '1.0.0',
    pluginApiVersion: 1,
    method: 'echo',
    params: params,
  );
}

Map<String, Object?> _invocationEnvelope(Object? params) => <String, Object?>{
  ..._PluginProtocolFixtures.invocationRequestV1,
  'params': params,
};

Map<String, Object?> _invocationResponseEnvelope(Object? result) => <String, Object?>{
  'version': 1,
  'result': result,
};

PluginHostCallRequestV1 _hostCallRequest(Object? payload) {
  return PluginHostCallRequestV1(
    invocationId: 'invocation-1',
    callId: 'call-1',
    pluginId: 'dev.shinga.fixture',
    pluginApiVersion: 1,
    operation: 'fixture.sync',
    deadlineEpochMilliseconds: 2000000000000,
    payload: payload,
  );
}

Map<String, Object?> _hostCallEnvelope(Object? payload) => <String, Object?>{
  ..._PluginProtocolFixtures.hostCallRequestV1,
  'payload': payload,
};

Map<String, Object?> _hostCallResponseEnvelope(Object? result) => <String, Object?>{
  'version': 1,
  'callId': 'call-1',
  'result': result,
};

List<String> _multibytePayloadForEnvelope(
  int targetBytes,
  Map<String, Object?> Function(Object? value) envelope,
) {
  final result = List<String>.filled(4, '');
  var remaining = targetBytes - _encodedLength(envelope(result));
  for (var index = 0; index < result.length && remaining > 0; index += 1) {
    final byteLength = remaining.clamp(0, PluginProtocolLimits.maxStringBytes);
    result[index] = '${'é' * (byteLength ~/ 2)}${byteLength.isOdd ? 'a' : ''}';
    remaining -= byteLength;
  }
  expect(remaining, 0, reason: 'Fixture must have enough bounded string capacity.');
  expect(result.join(), contains('é'));
  expect(_encodedLength(envelope(result)), targetBytes);
  return result;
}

int _encodedLength(Object? value) => utf8.encode(jsonEncode(value)).length;
