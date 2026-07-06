import 'package:fpdart/fpdart.dart';
import 'package:shinga/domain/domain.dart';
import 'package:shinga/features/features.dart';

/// Contract for managing user-specific data related to titles.
abstract class UserTitlesRepository {
  /// Adds a title to the user's list with the specified bookmark.
  Future<Either<AppFailure, Unit>> addUserTitle({
    required int titleId,
    required Bookmark bookmark,
  });

  /// Updates the user's data for a specific title.
  Future<Either<AppFailure, Unit>> updateUserTitle({
    required int titleId,
    required UpdateUserTitleParams updateParams,
  });
}
