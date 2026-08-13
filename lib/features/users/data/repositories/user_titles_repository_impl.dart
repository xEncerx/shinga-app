import 'package:shinga/core/types/types.dart';
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
  Future<Either<AppFailure, void>> addUserTitle({
    required int titleId,
    required Bookmark bookmark,
  }) {
    return ExceptionMapper.guardVoid(() async {
      await _userTitlesApiClient.addUserTitle(
        titleId,
        bookmark: BookmarkDTO.fromDomain(bookmark).value,
      );
    });
  }

  @override
  Future<Either<AppFailure, void>> updateUserTitle({
    required int titleId,
    required UpdateUserTitleParams updateParams,
  }) {
    return ExceptionMapper.guardVoid(() async {
      await _userTitlesApiClient.updateUserTitle(
        titleId: titleId,
        userData: UpdateUserTitleParamsDTO.fromDomain(updateParams),
      );
    });
  }
}
