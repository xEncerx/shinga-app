import 'package:fpdart/fpdart.dart';
import 'package:shinga/data/data.dart';
import 'package:shinga/domain/entities/bookmark.dart';
import 'package:shinga/domain/failures/app_failure.dart';
import 'package:shinga/features/features.dart';

/// Implementation of [UserTitlesRepository] backed by [UserTitlesApiClient].
class UserTitlesRepositoryImpl implements UserTitlesRepository {
  /// Creates a [UserTitlesRepositoryImpl] instance.
  const UserTitlesRepositoryImpl(UserTitlesApiClient userTitlesApiClient)
    : _userTitlesApiClient = userTitlesApiClient;

  final UserTitlesApiClient _userTitlesApiClient;

  @override
  Future<Either<AppFailure, Unit>> addUserTitle({
    required int titleId,
    required Bookmark bookmark,
  }) async {
    return ExceptionMapper.guard(() async {
      await _userTitlesApiClient.addUserTitle(
        titleId,
        bookmark: BookmarkDTO.fromDomain(bookmark).value,
      );

      return unit;
    });
  }

  @override
  Future<Either<AppFailure, Unit>> updateUserTitle({
    required int titleId,
    required UpdateUserTitleParams updateParams,
  }) async {
    return ExceptionMapper.guard(() async {
      await _userTitlesApiClient.updateUserTitle(
        titleId: titleId,
        userData: UpdateUserTitleParamsDTO.fromDomain(updateParams),
      );

      return unit;
    });
  }
}
