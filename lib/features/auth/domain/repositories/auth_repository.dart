import 'package:fpdart/fpdart.dart';
import 'package:shinga/domain/domain.dart';

/// Contract for authentication operations.
abstract class AuthRepository {
  /// Authenticates the user with the given [identifier] and [password].
  Future<Either<AppFailure, Unit>> login({
    required String identifier,
    required String password,
  });

  /// Clears the current session and removes stored tokens.
  Future<Either<AppFailure, Unit>> logout();

  /// Registers a new user with the given [username], [email], and [password].
  Future<Either<AppFailure, Unit>> signUp({
    required String username,
    required String email,
    required String password,
  });

  /// Requests a password reset for the user associated with the given [email].
  Future<Either<AppFailure, Unit>> requestPasswordReset({
    required String email,
    required AppLanguage emailLanguage,
  });

  /// Verifies the password reset code sent to the user's email.
  Future<Either<AppFailure, Unit>> verifyResetCode({
    required String email,
    required String code,
  });

  /// Resets the user's password using the provided [email], [code], and [newPassword].
  Future<Either<AppFailure, Unit>> resetPassword({
    required String email,
    required String code,
    required String newPassword,
  });

  /// Fetches the latest user profile from the API and updates the stored session.
  Future<Either<AppFailure, Unit>> refreshSession();
}
