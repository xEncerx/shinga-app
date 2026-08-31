import 'dart:collection';
import 'dart:convert';

import 'package:plugin_protocol/src/runtime/runtime.dart';

/// Validates and defensively copies JSON-compatible values under hard limits.
final class BoundedJsonCodec {
  /// Creates a codec whose configurable byte ceiling cannot exceed [hardMaxBytes].
  const BoundedJsonCodec({required this.maxBytes, required this.hardMaxBytes});

  /// The serialized UTF-8 byte ceiling used for this boundary.
  final int maxBytes;

  /// The release ceiling that [maxBytes] must not exceed.
  final int hardMaxBytes;

  /// Validates [value] and returns a deeply immutable JSON-compatible copy.
  Object? validateAndCopy(Object? value) {
    if (maxBytes <= 0 || maxBytes > hardMaxBytes) {
      throw const PluginProtocolException('json.byte_limit.invalid');
    }
    final state = _JsonValidationState();
    final copy = _copy(value, state, 0);
    final byteLength = utf8.encode(jsonEncode(copy)).length;
    if (byteLength > maxBytes) {
      throw const PluginProtocolException('json.serialized_too_large');
    }
    return copy;
  }

  Object? _copy(Object? value, _JsonValidationState state, int depth) {
    state.nodes += 1;
    if (state.nodes > PluginProtocolLimits.maxJsonNodes) {
      throw const PluginProtocolException('json.too_many_nodes');
    }
    if (value == null || value is bool) return value;
    if (value is String) {
      _checkString(value);
      return value;
    }
    if (value is int) {
      if (value < -9007199254740991 || value > 9007199254740991) {
        throw const PluginProtocolException('json.integer_not_js_safe');
      }
      return value;
    }
    if (value is double) {
      if (!value.isFinite) {
        throw const PluginProtocolException('json.number_not_finite');
      }
      return value;
    }
    if (value is num) {
      throw const PluginProtocolException('json.number_unsupported');
    }
    if (value is List<Object?>) {
      return _copyList(value, state, depth);
    }
    if (value is Map<Object?, Object?>) {
      return _copyMap(value, state, depth);
    }
    throw const PluginProtocolException('json.type_unsupported');
  }

  List<Object?> _copyList(List<Object?> value, _JsonValidationState state, int depth) {
    _checkContainer(value, value.length, state, depth);
    try {
      return List<Object?>.unmodifiable(
        value.map((item) => _copy(item, state, depth + 1)),
      );
    } finally {
      state.active.remove(value);
    }
  }

  Map<String, Object?> _copyMap(
    Map<Object?, Object?> value,
    _JsonValidationState state,
    int depth,
  ) {
    _checkContainer(value, value.length, state, depth);
    try {
      final copy = <String, Object?>{};
      for (final entry in value.entries) {
        final key = entry.key;
        if (key is! String) {
          throw const PluginProtocolException('json.object_key_not_string');
        }
        _checkString(key);
        copy[key] = _copy(entry.value, state, depth + 1);
      }
      return UnmodifiableMapView(copy);
    } finally {
      state.active.remove(value);
    }
  }

  void _checkContainer(Object value, int length, _JsonValidationState state, int depth) {
    if (depth > PluginProtocolLimits.maxJsonDepth) {
      throw const PluginProtocolException('json.too_deep');
    }
    if (length > PluginProtocolLimits.maxCollectionLength) {
      throw const PluginProtocolException('json.collection_too_large');
    }
    if (!state.active.add(value)) {
      throw const PluginProtocolException('json.cycle');
    }
  }

  void _checkString(String value) {
    if (utf8.encode(value).length > PluginProtocolLimits.maxStringBytes) {
      throw const PluginProtocolException('json.string_too_large');
    }
  }
}

final class _JsonValidationState {
  final Set<Object> active = HashSet<Object>.identity();
  int nodes = 0;
}
