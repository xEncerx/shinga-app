import 'package:either_dart/either.dart';

import '../../../core/core.dart';
import '../../../data/data.dart';

class UserRepository {
  UserRepository(this._remoteDataSource);

  final UserRemoteDataSource _remoteDataSource;

  Future<Either<ApiException, String>> getMe() async {
    final result = await _remoteDataSource.getMe();

    return result.fold(
      (error) => Left(error),
      (data) => Right(data["username"] as String),
    );
  }

  Future<Either<ApiException, Token>> login({
    required String username,
    required String password,
  }) async {
    final result = await _remoteDataSource.login(
      username: username,
      password: password,
    );

    return result.fold(
      (error) => Left(error),
      (data) => Right(Token.fromJson(data)),
    );
  }

  Future<Either<ApiException, UserRecoveryCode>> signUp({
    required String username,
    required String password,
  }) async {
    final result = await _remoteDataSource.signUp(
      username: username,
      password: password,
    );

    return result.fold(
      (error) => Left(error),
      (data) => Right(UserRecoveryCode.fromJson(data)),
    );
  }

  Future<Either<ApiException, UserRecoveryCode>> recoverPassword({
    required String username,
    required String newPassword,
    required String recoveryCode,
  }) async {
    final result = await _remoteDataSource.recoverPassword(
      username: username,
      newPassword: newPassword,
      recoveryCode: recoveryCode,
    );

    return result.fold(
      (error) => Left(error),
      (data) => Right(UserRecoveryCode.fromJson(data)),
    );
  }
}
