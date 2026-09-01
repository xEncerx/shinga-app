import 'dart:collection';

import 'package:plugin_protocol/plugin_protocol.dart';
import 'package:plugin_runtime/src/execution/plugin_runtime_adapter.dart';

/// Immutable registry used for both inspection dispatch and execution lookup.
final class PluginRuntimeAdapterRegistry {
  /// Creates a registry and rejects ambiguous adapter identities or extensions.
  PluginRuntimeAdapterRegistry(Iterable<PluginRuntimeAdapter> adapters) {
    final byId = <String, PluginRuntimeAdapter>{};
    final byExtension = <String, PluginRuntimeAdapter>{};
    for (final adapter in adapters) {
      if (adapter.id.isEmpty) {
        throw ArgumentError.value(adapter.id, 'adapter.id', 'must not be empty');
      }
      if (byId.containsKey(adapter.id)) {
        throw ArgumentError.value(adapter.id, 'adapters', 'contains a duplicate adapter id');
      }
      if (adapter.entryExtensions.isEmpty) {
        throw ArgumentError.value(
          adapter.entryExtensions,
          'adapter.entryExtensions',
          'must not be empty',
        );
      }
      byId[adapter.id] = adapter;
      for (final extension in adapter.entryExtensions) {
        if (!_validExtension(extension)) {
          throw ArgumentError.value(
            extension,
            'adapter.entryExtensions',
            'must be a dot-prefixed file extension',
          );
        }
        if (byExtension.containsKey(extension)) {
          throw ArgumentError.value(
            extension,
            'adapters',
            'contains a duplicate entry extension',
          );
        }
        byExtension[extension] = adapter;
      }
    }
    _byId = UnmodifiableMapView(byId);
    _byExtension = UnmodifiableMapView(byExtension);
  }

  late final Map<String, PluginRuntimeAdapter> _byId;
  late final Map<String, PluginRuntimeAdapter> _byExtension;

  /// Returns the adapter for the exact extension of [entry], or `null`.
  PluginRuntimeAdapter? adapterForEntry(PluginEntryPath entry) {
    return _byExtension[extensionOf(entry)];
  }

  /// Returns the adapter registered with [id], or `null`.
  PluginRuntimeAdapter? adapterById(String id) => _byId[id];

  /// Returns the exact case-sensitive extension of [entry].
  String extensionOf(PluginEntryPath entry) {
    final value = entry.value;
    final slash = value.lastIndexOf('/');
    final dot = value.lastIndexOf('.');
    return dot > slash && dot < value.length - 1 ? value.substring(dot) : '';
  }
}

bool _validExtension(String extension) {
  if (extension.length < 2 || !extension.startsWith('.')) return false;
  for (final codeUnit in extension.codeUnits.skip(1)) {
    final isDigit = codeUnit >= 0x30 && codeUnit <= 0x39;
    final isUpper = codeUnit >= 0x41 && codeUnit <= 0x5a;
    final isLower = codeUnit >= 0x61 && codeUnit <= 0x7a;
    if (!isDigit && !isUpper && !isLower) return false;
  }
  return true;
}
