import 'dart:io';
import 'dart:typed_data';

import 'package:path/path.dart' as p;
import 'package:plugin_runtime/src/package/reader/package_path.dart';
import 'package:plugin_runtime/src/package/reader/plugin_package_entry.dart';
import 'package:plugin_runtime/src/package/reader/plugin_package_read_exception.dart';
import 'package:plugin_runtime/src/package/reader/plugin_package_reader.dart';

/// Reads a plugin package stored in a filesystem directory.
final class DirectoryPluginPackageReader implements PluginPackageReader {
  /// Creates a reader rooted at [directory].
  DirectoryPluginPackageReader(Directory directory) : _directory = directory.absolute;

  final Directory _directory;

  @override
  Future<bool> exists(String relativePath) async => await stat(relativePath) != null;

  @override
  Future<PluginPackageEntry?> stat(String relativePath) async {
    final resolved = await _resolve(relativePath);
    try {
      await _rejectParentLinks(resolved, relativePath);
      final type = FileSystemEntity.typeSync(resolved, followLinks: false);
      if (type == FileSystemEntityType.notFound) {
        return null;
      }

      final entryType = switch (type) {
        FileSystemEntityType.file => PluginPackageEntryType.file,
        FileSystemEntityType.directory => PluginPackageEntryType.directory,
        FileSystemEntityType.link => PluginPackageEntryType.symbolicLink,
        _ => PluginPackageEntryType.other,
      };
      final size = entryType == PluginPackageEntryType.file
          ? await FileStat.stat(resolved).then((value) => value.size)
          : 0;
      return PluginPackageEntry(
        relativePath: relativePath,
        type: entryType,
        size: size,
      );
    } on PluginPackageReadException {
      rethrow;
    } on FileSystemException catch (error) {
      throw PluginPackageReadException(
        failure: PluginPackageReadFailure.io,
        relativePath: relativePath,
        cause: error,
      );
    }
  }

  @override
  Future<bool> refersToSameEntry(
    String firstRelativePath,
    String secondRelativePath,
  ) async {
    final first = await _resolve(firstRelativePath);
    final second = await _resolve(secondRelativePath);
    await _rejectParentLinks(first, firstRelativePath);
    await _rejectParentLinks(second, secondRelativePath);
    try {
      return await FileSystemEntity.identical(first, second);
    } on FileSystemException catch (error) {
      throw PluginPackageReadException(
        failure: PluginPackageReadFailure.io,
        relativePath: secondRelativePath,
        cause: error,
      );
    }
  }

  @override
  Future<List<int>> readBytes(
    String relativePath, {
    required int maxBytes,
  }) async {
    if (maxBytes < 0) {
      throw ArgumentError.value(maxBytes, 'maxBytes', 'must not be negative');
    }

    final entry = await stat(relativePath);
    if (entry == null) {
      throw PluginPackageReadException(
        failure: PluginPackageReadFailure.notFound,
        relativePath: relativePath,
      );
    }
    if (entry.type == PluginPackageEntryType.symbolicLink) {
      throw PluginPackageReadException(
        failure: PluginPackageReadFailure.symbolicLink,
        relativePath: relativePath,
      );
    }
    if (entry.type != PluginPackageEntryType.file) {
      throw PluginPackageReadException(
        failure: PluginPackageReadFailure.notFile,
        relativePath: relativePath,
      );
    }
    if (entry.size > maxBytes) {
      throw PluginPackageReadException(
        failure: PluginPackageReadFailure.tooLarge,
        relativePath: relativePath,
        maxBytes: maxBytes,
      );
    }

    final resolved = await _resolve(relativePath);
    final bytes = BytesBuilder(copy: false);
    try {
      await for (final chunk in File(resolved).openRead(0, maxBytes + 1)) {
        bytes.add(chunk);
        if (bytes.length > maxBytes) {
          throw PluginPackageReadException(
            failure: PluginPackageReadFailure.tooLarge,
            relativePath: relativePath,
            maxBytes: maxBytes,
          );
        }
      }
      return bytes.takeBytes();
    } on PluginPackageReadException {
      rethrow;
    } on FileSystemException catch (error) {
      throw PluginPackageReadException(
        failure: PluginPackageReadFailure.io,
        relativePath: relativePath,
        cause: error,
      );
    }
  }

  Future<String> _resolve(String relativePath) async {
    if (!isSafePackagePath(relativePath)) {
      throw PluginPackageReadException(
        failure: PluginPackageReadFailure.invalidPath,
        relativePath: relativePath,
      );
    }

    try {
      final root = await _directory.resolveSymbolicLinks();
      final resolved = p.normalize(p.joinAll([root, ...relativePath.split('/')]));
      if (!p.equals(root, resolved) && !p.isWithin(root, resolved)) {
        throw PluginPackageReadException(
          failure: PluginPackageReadFailure.outsidePackage,
          relativePath: relativePath,
        );
      }
      return resolved;
    } on PluginPackageReadException {
      rethrow;
    } on FileSystemException catch (error) {
      throw PluginPackageReadException(
        failure: PluginPackageReadFailure.io,
        relativePath: relativePath,
        cause: error,
      );
    }
  }

  Future<void> _rejectParentLinks(String resolved, String relativePath) async {
    var current = _directory.absolute.path;
    final segments = relativePath.split('/');
    for (final segment in segments.take(segments.length - 1)) {
      current = p.join(current, segment);
      final type = FileSystemEntity.typeSync(current, followLinks: false);
      if (type == FileSystemEntityType.link) {
        throw PluginPackageReadException(
          failure: PluginPackageReadFailure.symbolicLink,
          relativePath: relativePath,
        );
      }
      if (type == FileSystemEntityType.notFound) {
        return;
      }
    }

    final root = await _directory.resolveSymbolicLinks();
    final canonicalParent = await Directory(p.dirname(resolved)).resolveSymbolicLinks();
    if (!p.equals(root, canonicalParent) && !p.isWithin(root, canonicalParent)) {
      throw PluginPackageReadException(
        failure: PluginPackageReadFailure.outsidePackage,
        relativePath: relativePath,
      );
    }
  }
}
