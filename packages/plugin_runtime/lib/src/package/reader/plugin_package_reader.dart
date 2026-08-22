import 'package:plugin_runtime/src/package/reader/plugin_package_entry.dart';

/// Provides bounded access to files inside a plugin package.
abstract interface class PluginPackageReader {
  /// Whether an entry exists at [relativePath].
  Future<bool> exists(String relativePath);

  /// Reads metadata for [relativePath], or returns `null` when it is missing.
  Future<PluginPackageEntry?> stat(String relativePath);

  /// Whether two paths refer to the same physical package entry.
  Future<bool> refersToSameEntry(
    String firstRelativePath,
    String secondRelativePath,
  );

  /// Reads a complete regular file without exceeding [maxBytes].
  ///
  /// The method never returns truncated content. It throws a
  /// `PluginPackageReadException` when the path is unsafe, cannot be read, or
  /// exceeds the limit.
  Future<List<int>> readBytes(
    String relativePath, {
    required int maxBytes,
  });
}
