import 'package:fpdart/fpdart.dart';
import 'package:shinga/domain/domain.dart';

/// Contract for fetching title data, including user-specific information.
abstract class TitleRepository {
  /// Fetches a title by its [id], along with the current user's personal data for it.
  Future<Either<AppFailure, TitleWithUserDataEntity>> getTitle(String id);

  /// Searches for titles based on various optional filters, sorting and pagination parameters.
  Future<Either<AppFailure, TitleSearchData>> searchTitles({
    String? query,
    Bookmark? bookmark,
    TitleFilter filter = TitleFilter.empty,
    int? page,
    int? pageSize,
  });
}
