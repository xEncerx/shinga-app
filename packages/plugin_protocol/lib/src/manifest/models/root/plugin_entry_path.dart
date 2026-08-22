import 'package:meta/meta.dart';

/// A validated relative path to a plugin JavaScript entry point.
@immutable
final class PluginEntryPath {
  const PluginEntryPath._(this.value);

  static final RegExp _windowsDrivePattern = RegExp('^[A-Za-z]:');
  static final RegExp _urlSchemePattern = RegExp('^[A-Za-z][A-Za-z0-9+.-]*:');

  /// The package-relative POSIX path to the JavaScript file.
  final String value;

  /// Creates an entry path when [source] is syntactically safe.
  static PluginEntryPath? tryParse(String source) {
    return validate(source) ? PluginEntryPath._(source) : null;
  }

  /// Whether [source] is a safe relative path ending in `.js`.
  static bool validate(String source) {
    if (source.isEmpty ||
        !source.endsWith('.js') ||
        source.startsWith('/') ||
        source.startsWith(r'\') ||
        source.contains(r'\') ||
        source.contains(':') ||
        source.contains('\u0000') ||
        _windowsDrivePattern.hasMatch(source) ||
        _urlSchemePattern.hasMatch(source)) {
      return false;
    }

    return source
        .split('/')
        .every(
          (segment) => segment.isNotEmpty && segment != '.' && segment != '..',
        );
  }

  @override
  bool operator ==(Object other) => other is PluginEntryPath && other.value == value;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => value;
}
