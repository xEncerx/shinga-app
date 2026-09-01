import 'dart:collection';

import 'package:plugin_protocol/src/runtime/plugin_wire_codec.dart';
import 'package:plugin_protocol/src/runtime/plugin_wire_protocol.dart';

/// Immutable exact-version registry of trusted wire protocol codecs.
final class PluginWireProtocolRegistry {
  /// Creates a registry and rejects invalid or duplicate protocol versions.
  PluginWireProtocolRegistry(Iterable<PluginWireProtocol> protocols) {
    final byVersion = <int, PluginWireProtocol>{};
    for (final protocol in protocols) {
      final version = protocol.version;
      if (version <= 0 || version > 9007199254740991) {
        throw ArgumentError.value(
          version,
          'protocol.version',
          'must be a positive JS-safe integer',
        );
      }
      if (byVersion.containsKey(version)) {
        throw ArgumentError.value(version, 'protocols', 'contains a duplicate wire version');
      }
      byVersion[version] = protocol;
    }
    _byVersion = UnmodifiableMapView(Map<int, PluginWireProtocol>.of(byVersion));
    supportedVersions = Set.unmodifiable(_byVersion.keys);
  }

  /// Creates the production registry containing the frozen wire-v1 codec.
  factory PluginWireProtocolRegistry.builtIn() {
    return PluginWireProtocolRegistry(const [PluginWireProtocolV1()]);
  }

  late final Map<int, PluginWireProtocol> _byVersion;

  /// The exact wire versions derived solely from registered codecs.
  late final Set<int> supportedVersions;

  /// Returns the codec for exact [version], or `null` when unavailable.
  PluginWireProtocol? protocolForVersion(int version) => _byVersion[version];
}
