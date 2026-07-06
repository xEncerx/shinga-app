import 'package:hive_ce_flutter/hive_flutter.dart';
import 'package:storage/src/src.dart';

/// A [CollectionStorage] implementation backed by [Hive].
///
/// Stores typed objects in a named Hive box, persisted across app restarts.
///
/// Call [init] before using any other method.
///
/// Register any required Hive adapters (e.g. via `Hive.registerAdapters`)
/// before calling [init].
class HiveCollectionStorage<T> implements CollectionStorage<T> {
  /// Creates a [HiveCollectionStorage] for the given [boxName].
  HiveCollectionStorage({required String boxName}) : _boxName = boxName;

  final String _boxName;
  Box<T>? _box;

  Box<T> get _instance {
    final box = _box;
    if (box == null) {
      throw const StorageInitializationException(
        'HiveCollectionStorage is not initialized. Call init() first.',
      );
    }
    return box;
  }

  /// Initializes Hive and opens the box for this collection.
  ///
  /// The [dir] must be a **subdirectory name** (not an absolute path) relative to
  /// `getApplicationDocumentsDirectory()`. All boxes will be stored in `~/Documents/dir/`.
  @override
  Future<void> init([String? dir]) async {
    try {
      await Hive.initFlutter(dir);
      _box = await Hive.openBox<T>(_boxName);
    } catch (e, st) {
      Error.throwWithStackTrace(
        StorageInitializationException(
          'Failed to initialize Hive box "$_boxName": $e',
        ),
        st,
      );
    }
  }

  @override
  Future<T?> read(String id) async {
    try {
      return _instance.get(id);
    } on StorageException {
      rethrow;
    } catch (e, st) {
      Error.throwWithStackTrace(
        StorageReadException('Failed to read id "$id": $e'),
        st,
      );
    }
  }

  @override
  Future<List<T>> readAll() async {
    try {
      return _instance.values.toList();
    } on StorageException {
      rethrow;
    } catch (e, st) {
      Error.throwWithStackTrace(
        StorageReadException('Failed to readAll from "$_boxName": $e'),
        st,
      );
    }
  }

  @override
  Future<bool> containsKey(String id) async {
    try {
      return _instance.containsKey(id);
    } on StorageException {
      rethrow;
    } catch (e, st) {
      Error.throwWithStackTrace(
        StorageReadException('Failed to check key "$id": $e'),
        st,
      );
    }
  }

  @override
  Future<void> write(String id, T value) async {
    try {
      await _instance.put(id, value);
    } on StorageException {
      rethrow;
    } catch (e, st) {
      Error.throwWithStackTrace(
        StorageWriteException('Failed to write id "$id": $e'),
        st,
      );
    }
  }

  @override
  Future<void> delete(String id) async {
    try {
      await _instance.delete(id);
    } on StorageException {
      rethrow;
    } catch (e, st) {
      Error.throwWithStackTrace(
        StorageDeleteException('Failed to delete id "$id": $e'),
        st,
      );
    }
  }

  @override
  Future<void> clear() async {
    try {
      await _instance.clear();
    } on StorageException {
      rethrow;
    } catch (e, st) {
      Error.throwWithStackTrace(
        StorageDeleteException('Failed to clear box "$_boxName": $e'),
        st,
      );
    }
  }

  @override
  Stream<List<T>> watch() => _instance.watch().map((_) => _instance.values.toList());
}
