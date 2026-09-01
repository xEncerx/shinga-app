import 'dart:collection';

import 'package:plugin_protocol/plugin_protocol.dart';
import 'package:plugin_runtime/src/api/plugin_api_adapter.dart';

/// Immutable exact-version registry of trusted Plugin API adapters.
final class PluginApiRegistry {
  /// Creates a registry and validates every API-to-wire selection.
  PluginApiRegistry({
    required Iterable<PluginApiAdapter> adapters,
    required this.wireProtocols,
  }) {
    final byVersion = <int, PluginApiAdapter>{};
    for (final adapter in adapters) {
      final apiVersion = adapter.pluginApiVersion;
      final wireVersion = adapter.wireProtocolVersion;
      if (!_validVersion(apiVersion)) {
        throw ArgumentError.value(
          apiVersion,
          'adapter.pluginApiVersion',
          'must be a positive JS-safe integer',
        );
      }
      if (!_validVersion(wireVersion)) {
        throw ArgumentError.value(
          wireVersion,
          'adapter.wireProtocolVersion',
          'must be a positive JS-safe integer',
        );
      }
      if (wireProtocols.protocolForVersion(wireVersion) == null) {
        throw ArgumentError.value(
          wireVersion,
          'adapter.wireProtocolVersion',
          'is not registered',
        );
      }
      if (byVersion.containsKey(apiVersion)) {
        throw ArgumentError.value(
          apiVersion,
          'adapters',
          'contains a duplicate Plugin API version',
        );
      }
      byVersion[apiVersion] = adapter;
    }
    _byVersion = UnmodifiableMapView(Map<int, PluginApiAdapter>.of(byVersion));
    supportedVersions = Set.unmodifiable(_byVersion.keys);
  }

  /// Creates the production registry with Plugin API v1 mapped to wire v1.
  factory PluginApiRegistry.builtIn(PluginWireProtocolRegistry wireProtocols) {
    return PluginApiRegistry(
      adapters: const [PluginApiV1Adapter()],
      wireProtocols: wireProtocols,
    );
  }

  /// The wire registry against which every mapping was validated.
  final PluginWireProtocolRegistry wireProtocols;

  late final Map<int, PluginApiAdapter> _byVersion;

  /// The exact Plugin API versions derived solely from registered adapters.
  late final Set<int> supportedVersions;

  /// Returns the adapter for exact [version], or `null` when unavailable.
  PluginApiAdapter? adapterForVersion(int version) => _byVersion[version];
}

bool _validVersion(int value) => value > 0 && value <= 9007199254740991;
