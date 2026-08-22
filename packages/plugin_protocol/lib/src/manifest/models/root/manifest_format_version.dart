import 'package:meta/meta.dart';

/// A validated plugin manifest schema version.
@immutable
final class ManifestFormatVersion {
  const ManifestFormatVersion._(this.value);

  /// The positive manifest schema version number.
  final int value;

  /// Creates a manifest format version when [source] is valid.
  static ManifestFormatVersion? tryParse(int source) {
    return validate(source) ? ManifestFormatVersion._(source) : null;
  }

  /// Whether [source] is a positive manifest schema version number.
  static bool validate(int source) => source > 0;

  @override
  bool operator ==(Object other) => other is ManifestFormatVersion && other.value == value;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => value.toString();
}
