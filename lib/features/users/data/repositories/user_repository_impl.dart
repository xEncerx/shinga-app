import 'package:fpdart/fpdart.dart';
import 'package:shinga/data/data.dart';
import 'package:shinga/domain/domain.dart';
import 'package:shinga/features/features.dart';

/// Implementation of [UserRepository] backed by [UserApiClient].
class UserRepositoryImpl implements UserRepository {
  /// Creates a [UserRepositoryImpl] instance.
  const UserRepositoryImpl(UserApiClient userApiClient) : _userApiClient = userApiClient;

  final UserApiClient _userApiClient;

  @override
  Future<Either<AppFailure, UserEntity>> getCurrentUser() async {
    return ExceptionMapper.guard(() async {
      final response = await _userApiClient.getCurrentUser();
      return response.toDomain();
    });
  }

  @override
  Future<Either<AppFailure, UserStatisticsEntity>> getStatistics() async {
    return ExceptionMapper.guard(() async {
      final response = await _userApiClient.getStatistics();
      return response.toDomain();
    });
  }
}
