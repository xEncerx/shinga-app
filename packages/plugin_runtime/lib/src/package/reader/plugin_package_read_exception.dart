/// The reason a plugin package operation could not be completed.
enum PluginPackageReadFailure {
  /// The provided path is not a safe package-relative path.
  invalidPath,

  /// The requested package entry does not exist.
  notFound,

  /// The requested package entry is not a regular file.
  notFile,

  /// The requested file exceeds the supplied byte limit.
  tooLarge,

  /// The resolved entry is outside the package root.
  outsidePackage,

  /// The path contains a symbolic link or equivalent filesystem entry.
  symbolicLink,

  /// The requested entry changed while its bytes were being read.
  changedDuringRead,

  /// The underlying storage operation failed.
  io,
}

/// Reports a bounded or unsafe plugin package read failure.
final class PluginPackageReadException implements Exception {
  /// Creates a package read exception.
  const PluginPackageReadException({
    required this.failure,
    required this.relativePath,
    this.maxBytes,
    this.cause,
  });

  /// The reason the operation failed.
  final PluginPackageReadFailure failure;

  /// The package-relative path involved in the operation.
  final String relativePath;

  /// The byte limit that was exceeded, when applicable.
  final int? maxBytes;

  /// The underlying storage exception, when available.
  final Object? cause;

  @override
  String toString() => 'PluginPackageReadException($failure, $relativePath)';
}
