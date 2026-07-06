import 'package:fpdart/fpdart.dart';
import 'package:shinga/domain/domain.dart';
import 'package:shinga/features/features.dart';

/// Contract for fetching user profile data.
abstract class UserRepository {
  /// Returns the currently authenticated user's profile.
  Future<Either<AppFailure, UserEntity>> getCurrentUser();

  /// Returns aggregated statistics for the currently authenticated user.
  Future<Either<AppFailure, UserStatisticsEntity>> getStatistics();
}
