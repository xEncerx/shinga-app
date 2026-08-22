import 'package:meta/meta.dart';
import 'package:pub_semver/pub_semver.dart';

/// A validated Semantic Versioning 2.0.0 plugin version.
@immutable
final class PluginVersion implements Comparable<PluginVersion> {
  const PluginVersion._(this.value);

  static final RegExp _pattern = RegExp(
    r'^(0|[1-9][0-9]*)\.(0|[1-9][0-9]*)\.(0|[1-9][0-9]*)'
    r'(?:-([0-9A-Za-z-]+(?:\.[0-9A-Za-z-]+)*))?'
    r'(?:\+([0-9A-Za-z-]+(?:\.[0-9A-Za-z-]+)*))?$',
  );
  static final RegExp _numericIdentifierPattern = RegExp(r'^[0-9]+$');

  /// The SemVer string declared by the plugin.
  final String value;

  /// Creates a plugin version when [source] is valid SemVer.
  static PluginVersion? tryParse(String source) {
    if (!validate(source)) {
      return null;
    }

    return PluginVersion._(source);
  }

  /// Whether [source] follows Semantic Versioning 2.0.0.
  static bool validate(String source) {
    final match = _pattern.firstMatch(source);
    if (match == null) {
      return false;
    }

    final prerelease = match.group(4);
    if (prerelease == null) {
      return true;
    }

    return prerelease.split('.').every((identifier) {
      return !_numericIdentifierPattern.hasMatch(identifier) ||
          identifier == '0' ||
          !identifier.startsWith('0');
    });
  }

  /// Compares this version using Semantic Versioning precedence rules.
  ///
  /// Build metadata does not affect precedence, as required by SemVer 2.0.0.
  @override
  int compareTo(PluginVersion other) {
    final thisPrecedence = Version.parse(value.split('+').first);
    final otherPrecedence = Version.parse(other.value.split('+').first);
    return thisPrecedence.compareTo(otherPrecedence);
  }

  @override
  bool operator ==(Object other) => other is PluginVersion && other.value == value;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => value;
}
