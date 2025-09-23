import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:path_provider/path_provider.dart';

import '../../core/core.dart';

/// Model representing the size of the cache.
class CacheSize {
  CacheSize(this.size, this.suffix);

  double size;
  String suffix;
}

/// A service for managing cache directories and calculating cache size.
class CacheService {
  /// Returns the directory where cached images are stored.
  /// This directory is used by the `cached_network_image` package.
  static Future<Directory> get coverCacheDir async {
    final Directory tempDir = await getTemporaryDirectory();
    return Directory('${tempDir.path}/libCachedImageData');
  }

  static List<Directory> cacheFolders = [];

  /// Adds a directory to the list of cache folders.
  static void addCacheFolder(Directory dir) {
    cacheFolders.add(dir);
  }

  /// Returns the cache size in a human-readable format.
  Future<CacheSize> getCacheSize() async {
    int totalSize = 0;
    for (final dir in cacheFolders) {
      if (dir.existsSync()) {
        totalSize += await _getDirectorySize(dir);
      }
    }
    return _formatSize(totalSize);
  }

  /// Clears all cache directories.
  Future<void> clearCache() async {
    PaintingBinding.instance.imageCache.clear();
    await DefaultCacheManager().emptyCache();

    for (final dir in cacheFolders) {
      if (dir.existsSync()) {
        await dir.delete(recursive: true);
      }
    }
  }

  /// Returns the size of the cache directory in bytes.
  Future<int> _getDirectorySize(Directory dir) async {
    int size = 0;
    final List<FileSystemEntity> entities = await dir.list().toList();
    for (final entity in entities) {
      if (entity is File) {
        size += await entity.length();
      } else if (entity is Directory) {
        size += await _getDirectorySize(entity);
      }
    }
    return size;
  }

  /// Formats the size in bytes to a human-readable string.
  CacheSize _formatSize(int size) {
    if (size < 1024) {
      return CacheSize(size.toDouble(), 'B');
    } else if (size < 1024 * 1024) {
      final kb = size / 1024;
      return CacheSize(kb.roundToPrecision(2), 'KB');
    } else if (size < 1024 * 1024 * 1024) {
      final mb = size / (1024 * 1024);
      return CacheSize(mb.roundToPrecision(2), 'MB');
    } else {
      final gb = size / (1024 * 1024 * 1024);
      return CacheSize(gb.roundToPrecision(2), 'GB');
    }
  }
}
