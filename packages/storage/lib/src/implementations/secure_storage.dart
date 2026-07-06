import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:storage/src/exceptions/storage_exception.dart';
import 'package:storage/src/interface/key_value_storage.dart';

/// A [KeyValueStorage] implementation backed by [FlutterSecureStorage].
///
/// Stores data in the platform's secure enclave (Keychain on iOS, Keystore on Android).
/// Call [init] before using any other method.
class SecureStorage implements KeyValueStorage {
  late final FlutterSecureStorage _storage;

  static const _iosOptions = IOSOptions(
    accessibility: KeychainAccessibility.first_unlock,
  );

  @override
  Future<void> init() async {
    try {
      _storage = const FlutterSecureStorage(
        iOptions: _iosOptions,
      );
    } catch (e, st) {
      Error.throwWithStackTrace(
        StorageInitializationException('Failed to initialize SecureStorage: $e'),
        st,
      );
    }
  }

  @override
  Future<String?> read(String key) async {
    try {
      return await _storage.read(key: key);
    } catch (e, st) {
      Error.throwWithStackTrace(
        StorageReadException('Failed to read secure key "$key": $e'),
        st,
      );
    }
  }

  @override
  Future<Map<String, String>> readAll() async {
    try {
      return await _storage.readAll();
    } catch (e, st) {
      Error.throwWithStackTrace(
        StorageReadException('Failed to readAll from secure storage: $e'),
        st,
      );
    }
  }

  @override
  Future<bool> containsKey(String key) async {
    try {
      return await _storage.containsKey(key: key);
    } catch (e, st) {
      Error.throwWithStackTrace(
        StorageReadException('Failed to check secure key "$key": $e'),
        st,
      );
    }
  }

  @override
  Future<void> write(String key, String value) async {
    try {
      await _storage.write(key: key, value: value);
    } catch (e, st) {
      Error.throwWithStackTrace(
        StorageWriteException('Failed to write secure key "$key": $e'),
        st,
      );
    }
  }

  @override
  Future<void> delete(String key) async {
    try {
      await _storage.delete(key: key);
    } catch (e, st) {
      Error.throwWithStackTrace(
        StorageDeleteException('Failed to delete secure key "$key": $e'),
        st,
      );
    }
  }

  @override
  Future<void> clear() async {
    try {
      await _storage.deleteAll();
    } catch (e, st) {
      Error.throwWithStackTrace(
        StorageDeleteException('Failed to clear secure storage: $e'),
        st,
      );
    }
  }
}
