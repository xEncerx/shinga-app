import 'package:shinga/domain/failures/app_failure.dart';

/// The base sealed class for conflict failures (resource already exists).
sealed class ConflictFailure extends AppFailure {
  /// Creates a [ConflictFailure] with the given [code].
  const ConflictFailure({required super.code, super.details});
}

/// Failure when attempting to create a user that already exists.
final class UserAlreadyExistsFailure extends ConflictFailure {
  /// Creates a [UserAlreadyExistsFailure].
  const UserAlreadyExistsFailure({super.code = 'UserAlreadyExists', super.details});
}

/// Failure when attempting to assign a title that the user already has.
final class UserTitleAlreadyExistsFailure extends ConflictFailure {
  /// Creates a [UserTitleAlreadyExistsFailure].
  const UserTitleAlreadyExistsFailure({super.code = 'UserTitleAlreadyExists', super.details});
}
