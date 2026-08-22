/// The kind of entry stored in a plugin package.
enum PluginPackageEntryType {
  /// A regular file.
  file,

  /// A directory.
  directory,

  /// A symbolic link or platform-equivalent reparse point.
  symbolicLink,

  /// An unsupported filesystem entry kind.
  other,
}

/// Metadata describing one entry in a plugin package.
final class PluginPackageEntry {
  /// Creates package entry metadata.
  const PluginPackageEntry({
    required this.relativePath,
    required this.type,
    required this.size,
  });

  /// The normalized package-relative POSIX path.
  final String relativePath;

  /// The kind of package entry.
  final PluginPackageEntryType type;

  /// The file size in bytes, or zero for entries without byte contents.
  final int size;
}
