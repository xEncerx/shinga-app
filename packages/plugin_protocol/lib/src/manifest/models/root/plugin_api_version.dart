import 'package:meta/meta.dart';

/// A validated version of the API exposed to plugins.
@immutable
final class PluginApiVersion {
  const PluginApiVersion._(this.value);

  /// The positive protocol version number.
  final int value;

  /// Creates an API version when [source] is valid.
  static PluginApiVersion? tryParse(int source) {
    return validate(source) ? PluginApiVersion._(source) : null;
  }

  /// Whether [source] is a positive API version number.
  static bool validate(int source) => source > 0;

  @override
  bool operator ==(Object other) => other is PluginApiVersion && other.value == value;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => value.toString();
}
