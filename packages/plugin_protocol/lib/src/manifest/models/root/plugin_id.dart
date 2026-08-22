import 'package:meta/meta.dart';

/// A validated reverse-DNS plugin identifier.
@immutable
final class PluginId {
  const PluginId._(this.value);

  static const int _maxLength = 253;
  static final RegExp _segmentPattern = RegExp(
    r'^[a-z0-9](?:[a-z0-9-]{0,61}[a-z0-9])?$',
  );

  /// The normalized identifier used by the plugin protocol.
  final String value;

  /// Creates a plugin identifier when [source] is valid.
  static PluginId? tryParse(String source) {
    return validate(source) ? PluginId._(source) : null;
  }

  /// Whether [source] is a safe lowercase reverse-DNS identifier.
  static bool validate(String source) {
    if (source.isEmpty || source.length > _maxLength || source != source.toLowerCase()) {
      return false;
    }

    final segments = source.split('.');
    return segments.length >= 2 && segments.every(_segmentPattern.hasMatch);
  }

  @override
  bool operator ==(Object other) => other is PluginId && other.value == value;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => value;
}
