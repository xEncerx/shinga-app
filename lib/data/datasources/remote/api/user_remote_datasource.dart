import 'package:either_dart/either.dart';

import '../../../../core/core.dart';
import 'base_remote_datasource.dart';

class UserRemoteDataSource extends BaseRemoteDataSource {
  UserRemoteDataSource(super.dio);

  Future<Either<ApiException, Map<String, dynamic>>> getMe() async {
    return executeRequest(
      endpoint: "/users/me",
      method: "GET",
    );
  }

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
