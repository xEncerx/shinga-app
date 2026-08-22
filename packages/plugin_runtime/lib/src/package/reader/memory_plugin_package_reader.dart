import 'dart:typed_data';

import 'package:plugin_runtime/src/package/reader/package_path.dart';
import 'package:plugin_runtime/src/package/reader/plugin_package_entry.dart';
import 'package:plugin_runtime/src/package/reader/plugin_package_read_exception.dart';
import 'package:plugin_runtime/src/package/reader/plugin_package_reader.dart';

/// Reads an in-memory plugin package for deterministic tests.
final class MemoryPluginPackageReader implements PluginPackageReader {
  /// Creates a reader from defensive copies of [files] and [directories].
  MemoryPluginPackageReader({
    Map<String, List<int>> files = const {},
    Set<String> directories = const {},
  }) : _files = {
         for (final entry in files.entries)
           _validatedPath(entry.key): Uint8List.fromList(entry.value),
       },
       _directories = {for (final path in directories) _validatedPath(path)};

  final Map<String, Uint8List> _files;
  final Set<String> _directories;

  @override
  Future<bool> exists(String relativePath) async => await stat(relativePath) != null;

  @override
  Future<PluginPackageEntry?> stat(String relativePath) async {
    _validatePath(relativePath);
    final bytes = _files[relativePath];
    if (bytes != null) {
      return PluginPackageEntry(
        relativePath: relativePath,
        type: PluginPackageEntryType.file,
        size: bytes.length,
      );
    }
    if (_directories.contains(relativePath)) {
      return PluginPackageEntry(
        relativePath: relativePath,
        type: PluginPackageEntryType.directory,
        size: 0,
      );
    }
    return null;
  }

  @override
  Future<bool> refersToSameEntry(
    String firstRelativePath,
    String secondRelativePath,
  ) async {
    _validatePath(firstRelativePath);
    _validatePath(secondRelativePath);
    return firstRelativePath == secondRelativePath && await exists(firstRelativePath);
  }

  @override
  Future<List<int>> readBytes(
    String relativePath, {
    required int maxBytes,
  }) async {
    if (maxBytes < 0) {
      throw ArgumentError.value(maxBytes, 'maxBytes', 'must not be negative');
    }
    _validatePath(relativePath);
    final bytes = _files[relativePath];
    if (bytes == null) {
      throw PluginPackageReadException(
        failure: _directories.contains(relativePath)
            ? PluginPackageReadFailure.notFile
            : PluginPackageReadFailure.notFound,
        relativePath: relativePath,
      );
    }
    if (bytes.length > maxBytes) {
      throw PluginPackageReadException(
        failure: PluginPackageReadFailure.tooLarge,
        relativePath: relativePath,
        maxBytes: maxBytes,
      );
    }
    return Uint8List.fromList(bytes);
  }

  static String _validatedPath(String relativePath) {
    _validatePath(relativePath);
    return relativePath;
  }

  static void _validatePath(String relativePath) {
    if (!isSafePackagePath(relativePath)) {
      throw PluginPackageReadException(
        failure: PluginPackageReadFailure.invalidPath,
        relativePath: relativePath,
      );
    }
  }
}
