import 'package:shinga/domain/failures/app_failure.dart';

/// The base sealed class for resource-not-found failures.
sealed class ResourceFailure extends AppFailure {
  /// Creates a [ResourceFailure] with the given [code].
  const ResourceFailure({required super.code, super.details});
}

/// Failure when the requested title resource is not found.
final class TitleNotFoundFailure extends ResourceFailure {
  /// Creates a [TitleNotFoundFailure].
  const TitleNotFoundFailure({super.code = 'TitleNotFound', super.details});
}

/// Failure when the requested user is not found.
final class UserNotFoundFailure extends ResourceFailure {
  /// Creates a [UserNotFoundFailure].
  const UserNotFoundFailure({super.code = 'UserNotFound', super.details});
}

/// Failure when the requested user title is not found.
final class UserTitleNotFoundFailure extends ResourceFailure {
  /// Creates a [UserTitleNotFoundFailure].
  const UserTitleNotFoundFailure({super.code = 'UserTitleNotFound', super.details});
}
