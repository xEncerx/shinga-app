import 'dart:convert';

import 'package:plugin_protocol/plugin_protocol.dart';
import 'package:plugin_runtime/plugin_runtime.dart';
import 'package:test/test.dart';

void main() {
  group('PluginApiRegistry', () {
    test('exact-resolves API1 and API2 sharing wire v1', () {
      const wire1 = PluginWireProtocolV1();
      final wireProtocols = PluginWireProtocolRegistry(const [
        wire1,
        _FixtureWireProtocolV2(),
      ]);
      const api1 = PluginApiV1Adapter();
      const api2 = _FixtureApiAdapter(apiVersion: 2, wireVersion: 1);
      final registry = PluginApiRegistry(
        adapters: const [api1, api2],
        wireProtocols: wireProtocols,
      );

      expect(registry.adapterForVersion(1), same(api1));
      expect(registry.adapterForVersion(2), same(api2));
      expect(registry.adapterForVersion(3), isNull);
      expect(registry.adapterForVersion(2)?.wireProtocolVersion, 1);
      expect(registry.supportedVersions, {1, 2});
      expect(registry.wireProtocols.supportedVersions, {1, 2});
      expect(() => registry.supportedVersions.add(3), throwsUnsupportedError);

      final selectedApi1Wire = registry.wireProtocols.protocolForVersion(
        registry.adapterForVersion(1)!.wireProtocolVersion,
      );
      final selectedApi2Wire = registry.wireProtocols.protocolForVersion(
        registry.adapterForVersion(2)!.wireProtocolVersion,
      );
      expect(selectedApi1Wire, same(wire1));
      expect(selectedApi2Wire, same(wire1));
      expect(selectedApi1Wire?.version, 1);
      expect(selectedApi2Wire?.version, 1);

      final encoded = jsonEncode(
        selectedApi2Wire!.encodeInvocationRequest(
          PluginInvocationRequestV1(
            invocationId: 'invocation-1',
            pluginId: 'dev.shinga.fixture',
            pluginVersion: '1.0.0',
            pluginApiVersion: 2,
            method: 'run',
            params: null,
          ),
        ),
      );
      expect(
        encoded,
        '{"version":1,"invocationId":"invocation-1",'
        '"pluginId":"dev.shinga.fixture","pluginVersion":"1.0.0",'
        '"pluginApiVersion":2,"method":"run","params":null}',
      );
    });

    test('rejects duplicate, invalid, and unavailable mappings', () {
      final wireProtocols = PluginWireProtocolRegistry.builtIn();

      expect(
        () => PluginApiRegistry(
          adapters: const [
            PluginApiV1Adapter(),
            _FixtureApiAdapter(apiVersion: 1, wireVersion: 1),
          ],
          wireProtocols: wireProtocols,
        ),
        throwsArgumentError,
      );
      for (final adapter in const [
        _FixtureApiAdapter(apiVersion: 0, wireVersion: 1),
        _FixtureApiAdapter(apiVersion: 2, wireVersion: 0),
        _FixtureApiAdapter(apiVersion: 2, wireVersion: 2),
      ]) {
        expect(
          () => PluginApiRegistry(
            adapters: [adapter],
            wireProtocols: wireProtocols,
          ),
          throwsArgumentError,
        );
      }
    });
  });
}

final class _FixtureApiAdapter implements PluginApiAdapter {
  const _FixtureApiAdapter({required this.apiVersion, required this.wireVersion});

  final int apiVersion;
  final int wireVersion;

  @override
  int get pluginApiVersion => apiVersion;

  @override
  int get wireProtocolVersion => wireVersion;
}

final class _FixtureWireProtocolV2 implements PluginWireProtocol {
  const _FixtureWireProtocolV2();

  @override
  int get version => 2;

  @override
  Never noSuchMethod(Invocation invocation) {
    throw UnsupportedError('The future codec must not encode wire-v1 fixtures.');
  }
}
