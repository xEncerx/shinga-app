import 'package:either_dart/either.dart';

import '../../../../core/core.dart';
import 'base_remote_datasource.dart';

/// A data source for user-related operations that interact with the remote API.
///
/// Provides methods to interact with user endpoints including:
/// - Authentication (login/signup)
/// - User profile retrieval
/// - Password recovery
class UserRemoteDataSource extends BaseRemoteDataSource {
  /// Creates a new instance of [UserRemoteDataSource].
  /// 
  /// - `dio` - The Dio HTTP client instance used for making API requests.
  UserRemoteDataSource(super.dio);

  /// Executes a request to get the current user's information.
  /// 
  /// Returns a map with user data.
  Future<Either<ApiException, Map<String, dynamic>>> getMe() async {
    return executeRequest(
      endpoint: "/users/me",
      method: "GET",
    );
  }

  /// Executes a request to log in a user into the system
  /// - `username` - The username of the user.
  /// - `password` - The password for authentication.
  /// 
  /// Returns a map with login data.
  Future<Either<ApiException, Map<String, dynamic>>> login({
    required String username,
    required String password,
  }) async {
    return executeRequest(
      endpoint: "/users/login/access-token",
      method: "POST",
      data: <String, dynamic>{
        "username": username,
        "password": password,
      },
      headers: {
        "Content-Type": "application/x-www-form-urlencoded",
      },
    );
  }

  /// Executes a request to sign up a new user in the system.
  /// - `username` - The username of the user.
  /// - `password` - The password for the new user.
  /// 
  /// Returns a map with sign-up data/message.
  Future<Either<ApiException, Map<String, dynamic>>> signUp({
    required String username,
    required String password,
  }) async {
    return executeRequest(
      endpoint: "/users/signup",
      method: "POST",
      data: <String, dynamic>{
        "username": username,
        "password": password,
      },
    );
  }

  /// Executes a request to recover password for a user.
  /// - `username` - The username of the user.
  /// - `newPassword` - The new password to set.
  /// - `recoveryCode` - The recovery code given to the user.
  /// 
  /// Returns a map with new recovery code.
  Future<Either<ApiException, Map<String, dynamic>>> recoverPassword({
    required String username,
    required String newPassword,
    required String recoveryCode,
  }) async {
    return executeRequest(
      endpoint: "/users/password/recover",
      method: "PATCH",
      data: <String, dynamic>{
        "username": username,
        "new_password": newPassword,
        "recovery_code": recoveryCode,
      },
    );
  }
}
