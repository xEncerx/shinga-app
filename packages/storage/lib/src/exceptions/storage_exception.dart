/// Base class for all storage-related exceptions.
sealed class StorageException implements Exception {
  const StorageException(this.message);

  /// A descriptive message about the exception.
  final String message;
}

/// Thrown when the storage operation is denied due to insufficient permissions.
final class StoragePermissionDeniedException extends StorageException {
  /// Creates a [StoragePermissionDeniedException] instance.
  const StoragePermissionDeniedException(super.message);
}

/// Thrown when a read operation from storage fails.
final class StorageReadException extends StorageException {
  /// Creates a [StorageReadException] instance.
  const StorageReadException(super.message);
}

/// Thrown when a write operation to storage fails.
final class StorageWriteException extends StorageException {
  /// Creates a [StorageWriteException] instance.
  const StorageWriteException(super.message);
}

/// Thrown when a delete operation from storage fails.
final class StorageDeleteException extends StorageException {
  /// Creates a [StorageDeleteException] instance.
  const StorageDeleteException(super.message);
}

/// Thrown when the storage fails to initialize.
final class StorageInitializationException extends StorageException {
  /// Creates a [StorageInitializationException] instance.
  const StorageInitializationException(super.message);
}
