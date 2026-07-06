import 'package:shinga/domain/failures/app_failure.dart';

/// The base sealed class for authentication-related failures.
sealed class AuthFailure extends AppFailure {
  /// Creates an [AuthFailure] with the given [code].
  const AuthFailure({required super.code, super.details});
}

/// Failure when the request lacks valid authentication credentials (HTTP 401).
final class UnauthorizedFailure extends AuthFailure {
  /// Creates an [UnauthorizedFailure] with an optional [code] and optional details.
  const UnauthorizedFailure({super.code = 'Unauthorized', super.details});
}

/// Failure when required credentials are missing from the request.
final class MissingCredentialsFailure extends AuthFailure {
  /// Creates a [MissingCredentialsFailure].
  const MissingCredentialsFailure({super.code = 'MissingCredentials', super.details});
}

/// Failure when the provided login credentials are incorrect.
final class InvalidCredentialsFailure extends AuthFailure {
  /// Creates an [InvalidCredentialsFailure].
  const InvalidCredentialsFailure({super.code = 'InvalidCredentials', super.details});
}

/// Failure when the authentication token is invalid or expired.
final class InvalidTokenCredentialsFailure extends AuthFailure {
  /// Creates an [InvalidTokenCredentialsFailure].
  const InvalidTokenCredentialsFailure({super.code = 'InvalidTokenCredentials', super.details});
}

/// Failure when the verification code does not exist or has expired.
final class VerificationCodeNotFoundFailure extends AuthFailure {
  /// Creates a [VerificationCodeNotFoundFailure].
  const VerificationCodeNotFoundFailure({
    super.code = 'VerificationCodeNotFound',
    super.details,
  });
}

/// Failure when the provided verification code is incorrect.
final class InvalidVerificationCodeFailure extends AuthFailure {
  /// Creates an [InvalidVerificationCodeFailure].
  const InvalidVerificationCodeFailure({
    super.code = 'InvalidVerificationCode',
    super.details,
  });
}
