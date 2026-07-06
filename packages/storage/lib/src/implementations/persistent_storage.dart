import 'package:shared_preferences/shared_preferences.dart';
import 'package:storage/src/src.dart';

/// A [KeyValueStorage] implementation backed by [SharedPreferences].
///
/// Stores data persistently across application restarts using platform-native
/// key-value storage. Call [init] before using any other method.
class PersistentStorage implements KeyValueStorage {
  SharedPreferences? _prefs;

  SharedPreferences get _instance {
    final prefs = _prefs;
    if (prefs == null) {
      throw const StorageInitializationException(
        'SharedPrefsStorage is not initialized. Call init() first.',
      );
    }
    return prefs;
  }

  @override
  Future<void> init() async {
    try {
      _prefs = await SharedPreferences.getInstance();
    } catch (e, st) {
      Error.throwWithStackTrace(
        StorageInitializationException('Failed to initialize SharedPreferences: $e'),
        st,
      );
    }
  }

  @override
  Future<String?> read(String key) async {
    try {
      return _instance.getString(key);
    } on StorageException {
      rethrow;
    } catch (e, st) {
      Error.throwWithStackTrace(
        StorageReadException('Failed to read key "$key": $e'),
        st,
      );
    }
  }

  @override
  Future<Map<String, String>> readAll() async {
    try {
      final keys = _instance.getKeys();
      final result = <String, String>{};
      for (final key in keys) {
        final value = _instance.getString(key);
        if (value != null) result[key] = value;
      }
      return result;
    } on StorageException {
      rethrow;
    } catch (e, st) {
      Error.throwWithStackTrace(
        StorageReadException('Failed to readAll: $e'),
        st,
      );
    }
  }

  @override
  Future<bool> containsKey(String key) async {
    try {
      return _instance.containsKey(key);
    } on StorageException {
      rethrow;
    } catch (e, st) {
      Error.throwWithStackTrace(
        StorageReadException('Failed to check key "$key": $e'),
        st,
      );
    }
  }

  @override
  Future<void> write(String key, String value) async {
    try {
      await _instance.setString(key, value);
    } on StorageException {
      rethrow;
    } catch (e, st) {
      Error.throwWithStackTrace(
        StorageWriteException('Failed to write key "$key": $e'),
        st,
      );
    }
  }

  @override
  Future<void> delete(String key) async {
    try {
      final existed = await containsKey(key);
      if (!existed) {
        throw StorageDeleteException('Key "$key" not found.');
      }
      await _instance.remove(key);
    } on StorageException {
      rethrow;
    } catch (e, st) {
      Error.throwWithStackTrace(
        StorageDeleteException('Failed to delete key "$key": $e'),
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
        StorageDeleteException('Failed to clear storage: $e'),
        st,
      );
    }
  }
}
