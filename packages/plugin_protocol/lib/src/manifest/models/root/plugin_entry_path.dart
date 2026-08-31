import 'package:meta/meta.dart';
import 'package:plugin_protocol/src/package/plugin_package_path.dart';

const _allowedPluginEntryExtensions = {'.dart'};

/// A validated relative path to an interpreted plugin entry point.
@immutable
final class PluginEntryPath {
  const PluginEntryPath._(this.value);

  /// The package-relative POSIX path to the file.
  final String value;

  /// Creates an entry path when [source] is syntactically safe.
  static PluginEntryPath? tryParse(String source) {
    return validate(source) ? PluginEntryPath._(source) : null;
  }

  /// Whether [source] is a safe relative path ending in `.dart`.
  static bool validate(String source) {
    return _allowedPluginEntryExtensions.any(source.endsWith) &&
        isPortablePluginPackagePath(source);
  }

  @override
  bool operator ==(Object other) => other is PluginEntryPath && other.value == value;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => value;
}
