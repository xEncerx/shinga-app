import 'package:fpdart/fpdart.dart';
import 'package:shinga/data/data.dart';
import 'package:shinga/domain/domain.dart';
import 'package:shinga/features/features.dart';

/// Implementation of [TitleRepository] backed by [TitleApiClient] and [TitleFormApiClient].
class TitleRepositoryImpl implements TitleRepository {
  /// Creates a [TitleRepositoryImpl] instance.
  const TitleRepositoryImpl(
    TitleApiClient titleApiClient,
  ) : _titleApiClient = titleApiClient;

  final TitleApiClient _titleApiClient;

  @override
  Future<Either<AppFailure, TitleWithUserDataEntity>> getTitle(String id) async {
    return ExceptionMapper.guard(() async {
      final response = await _titleApiClient.getTitle(id);
      return response.content.toDomain();
    });
  }

  @override
  Future<Either<AppFailure, TitleSearchData>> searchTitles({
    String? query,
    Bookmark? bookmark,
    TitleFilter filter = TitleFilter.empty,
    int? page,
    int? pageSize,
  }) async {
    return ExceptionMapper.guard(() async {
      final response = await _titleApiClient.searchTitles(
        query: query,
        type: filter.type != null ? TitleTypeDTO.fromDomain(filter.type!).value : null,
        status: filter.status != null ? TitleStatusDTO.fromDomain(filter.status!).value : null,
        genres: filter.genres?.map((genre) => genre.name).toList(),
        categories: filter.categories?.map((category) => category.name).toList(),
        bookmark: bookmark != null ? BookmarkDTO.fromDomain(bookmark).value : null,
        minRating: filter.minRating,
        maxRating: filter.maxRating,
        minChapters: filter.minChapters,
        maxChapters: filter.maxChapters,
        sortBy: filter.sortBy != null ? TitleSortByDTO.fromDomain(filter.sortBy!).value : null,
        sortOrder: filter.sortOrder != null
            ? TitleSortOrderDTO.fromDomain(filter.sortOrder!).value
            : null,
        page: page,
        pageSize: pageSize,
      );
      return response.toDomain();
    });
  }
}
