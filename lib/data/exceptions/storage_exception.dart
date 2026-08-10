/// Base class for persistence-related exceptions.
sealed class StorageException implements Exception {
  /// Creates a persistence exception with a diagnostic [message].
  const StorageException(this.message);

  /// A diagnostic message intended for logs.
  final String message;
}

/// Indicates that a persistence resource failed to initialize.
final class StorageInitializationException extends StorageException {
  /// Creates an initialization exception.
  const StorageInitializationException(super.message);
}

/// Indicates that a persistence read failed.
final class StorageReadException extends StorageException {
  /// Creates a read exception.
  const StorageReadException(super.message);
}

/// Indicates that a persistence write failed.
final class StorageWriteException extends StorageException {
  /// Creates a write exception.
  const StorageWriteException(super.message);
}

/// Indicates that a persistence deletion failed.
final class StorageDeleteException extends StorageException {
  /// Creates a delete exception.
  const StorageDeleteException(super.message);
}
