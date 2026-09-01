import 'dart:convert';

import 'package:plugin_protocol/plugin_protocol.dart';
import 'package:test/test.dart';

void main() {
  group('PluginWireProtocolRegistry', () {
    test('exact-resolves side-by-side implementations', () {
      const wire1 = PluginWireProtocolV1();
      const wire2 = _FixtureWireProtocol(2);
      final registry = PluginWireProtocolRegistry([wire1, wire2]);

      expect(registry.protocolForVersion(1), same(wire1));
      expect(registry.protocolForVersion(2), same(wire2));
      expect(registry.protocolForVersion(3), isNull);
      expect(registry.supportedVersions, {1, 2});
      expect(() => registry.supportedVersions.add(3), throwsUnsupportedError);

      final request = PluginInvocationRequestV1(
        invocationId: 'invocation-1',
        pluginId: 'dev.shinga.fixture',
        pluginVersion: '1.0.0',
        pluginApiVersion: 2,
        method: 'run',
        params: null,
      );
      expect(wire1.encodeInvocationRequest(request), {
        'version': 1,
        'invocationId': 'invocation-1',
        'pluginId': 'dev.shinga.fixture',
        'pluginVersion': '1.0.0',
        'pluginApiVersion': 2,
        'method': 'run',
        'params': null,
      });
      expect(
        jsonEncode(registry.protocolForVersion(1)!.encodeInvocationRequest(request)),
        '{"version":1,"invocationId":"invocation-1",'
        '"pluginId":"dev.shinga.fixture","pluginVersion":"1.0.0",'
        '"pluginApiVersion":2,"method":"run","params":null}',
      );
    });

    test('rejects duplicate and invalid versions', () {
      expect(
        () => PluginWireProtocolRegistry(const [
          PluginWireProtocolV1(),
          _FixtureWireProtocol(1),
        ]),
        throwsArgumentError,
      );
      expect(
        () => PluginWireProtocolRegistry(const [_FixtureWireProtocol(0)]),
        throwsArgumentError,
      );
    });
  });
}

final class _FixtureWireProtocol implements PluginWireProtocol {
  const _FixtureWireProtocol(this.version);

  static const _wire1 = PluginWireProtocolV1();

  @override
  final int version;

  @override
  PluginHostCallRequest createHostCallRequest({
    required String invocationId,
    required String callId,
    required String pluginId,
    required int pluginApiVersion,
    required String operation,
    required int deadlineEpochMilliseconds,
    required Object? payload,
  }) {
    return _wire1.createHostCallRequest(
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
  PluginHostCallResponse createHostCallFailure({
    required String callId,
    required PluginError error,
  }) => _wire1.createHostCallFailure(callId: callId, error: error);

  @override
  PluginInvocationResponse createInvocationFailure(PluginError error) {
    return _wire1.createInvocationFailure(error);
  }

  @override
  PluginHostCallRequest decodeHostCallRequest(Object? value) {
    return _wire1.decodeHostCallRequest(value);
  }

  @override
  PluginHostCallResponse decodeHostCallResponse(Object? value) {
    return _wire1.decodeHostCallResponse(value);
  }

  @override
  PluginInvocationRequest decodeInvocationRequest(Object? value) {
    return _wire1.decodeInvocationRequest(value);
  }

  @override
  PluginInvocationResponse decodeInvocationResponse(Object? value) {
    return _wire1.decodeInvocationResponse(value);
  }

  @override
  Map<String, Object?> encodeHostCallRequest(PluginHostCallRequest request) {
    return _wire1.encodeHostCallRequest(request);
  }

  @override
  Map<String, Object?> encodeHostCallResponse(PluginHostCallResponse response) {
    return _wire1.encodeHostCallResponse(response);
  }

  @override
  Map<String, Object?> encodeInvocationRequest(PluginInvocationRequest request) {
    return _wire1.encodeInvocationRequest(request);
  }

  @override
  Map<String, Object?> encodeInvocationResponse(PluginInvocationResponse response) {
    return _wire1.encodeInvocationResponse(response);
  }
}
