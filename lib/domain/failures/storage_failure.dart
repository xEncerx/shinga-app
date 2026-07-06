import 'package:shinga/domain/domain.dart';

/// Failures related to storage operations.
sealed class StorageFailure extends AppFailure {
  const StorageFailure({required super.code, super.details});
}

/// Failure when reading from storage fails.
final class StorageReadFailure extends StorageFailure {
  /// Creates a [StorageReadFailure] instance.
  const StorageReadFailure({super.code = 'StorageReadFailure', super.details});
}

/// Failure when writing to storage fails.
final class StorageWriteFailure extends StorageFailure {
  /// Creates a [StorageWriteFailure] instance.
  const StorageWriteFailure({super.code = 'StorageWriteFailure', super.details});
}

/// Failure when deleting from storage fails.
final class StorageDeleteFailure extends StorageFailure {
  /// Creates a [StorageDeleteFailure] instance.
  const StorageDeleteFailure({super.code = 'StorageDeleteFailure', super.details});
}

/// Failure when an unknown error occurs during storage operations.
final class UnknownStorageFailure extends StorageFailure {
  /// Creates an [UnknownStorageFailure] instance.
  const UnknownStorageFailure({super.code = 'UnknownStorageFailure', super.details});
}
