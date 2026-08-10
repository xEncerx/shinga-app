import 'package:shinga/data/exceptions/storage_exception.dart';

/// Translates infrastructure errors into operation-specific storage errors.
abstract final class StorageExceptionGuard {
  /// Executes a read operation while preserving its original stack trace.
  static Future<T> read<T>(Future<T> Function() operation) => _guard(
    operation,
    StorageReadException.new,
  );

  /// Executes a write operation while preserving its original stack trace.
  static Future<T> write<T>(Future<T> Function() operation) => _guard(
    operation,
    StorageWriteException.new,
  );

  /// Executes a delete operation while preserving its original stack trace.
  static Future<T> delete<T>(Future<T> Function() operation) => _guard(
    operation,
    StorageDeleteException.new,
  );

  static Future<T> _guard<T>(
    Future<T> Function() operation,
    StorageException Function(String message) mapError,
  ) async {
    try {
      return await operation();
    } on StorageException {
      rethrow;
    } on Object catch (error, stackTrace) {
      Error.throwWithStackTrace(mapError(error.toString()), stackTrace);
    }
  }
}
