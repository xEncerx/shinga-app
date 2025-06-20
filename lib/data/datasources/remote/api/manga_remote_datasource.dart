import 'package:either_dart/either.dart';

import '../../../../core/core.dart';
import '../../../data.dart';

/// Remote data source for manga-related API operations.
/// 
/// Provides methods to interact with manga endpoints including:
/// - Creating new manga entries
/// - Updating user manga data
/// - Searching for manga
/// - Getting user's manga library
class MangaRemoteDataSource extends BaseRemoteDataSource {
  /// Creates a new instance of [MangaRemoteDataSource].
  /// 
  /// - `dio` - The Dio HTTP client instance used for making API requests.
  MangaRemoteDataSource(super.dio);

  /// Executes a request to create a new manga in the API.
  /// - `manga` - The `Manga` object to be created.
  /// 
  /// Returns a message indicating the success or failure of the operation.
  Future<Either<ApiException, Map<String, dynamic>>> createManga({
    required Manga manga,
  }) async {
    return executeRequest(
      endpoint: "/titles/create",
      method: "POST",
      data: manga.toJson(),
    );
  }

  /// Executes a request to update user manga data in the API.
  /// - `mangaId` - The ID of the manga to be updated.
  /// - `currentUrl` - The current URL of the manga.
  /// - `section` - The current reading section of the manga, represented by the `MangaSection` enum.
  /// - `lastRead` - The date and time when the manga was last read.
  /// 
  /// Returns a message indicating the success or failure of the operation.
  Future<Either<ApiException, Map<String, dynamic>>> updateMangaData({
    required String mangaId,
    String currentUrl = "",
    MangaSection? section,
    DateTime? lastRead,
  }) async {
    lastRead ??= DateTime.now();

    return executeRequest(
      endpoint: "/titles/me/update",
      method: "PUT",
      data: <String, dynamic>{
        "manga_id": mangaId,
        "current_url": currentUrl,
        "section": section?.name,
        "last_read": lastRead.toIso8601String(),
      },
    );
  }

  /// Executes a request to get a list of suggested names based on a query.
  /// - `query` - The query string to suggest names for.
  /// - `source` - The source of the manga, represented by the [MangaSource] enum.
  /// 
  /// Returns a map containing the suggested names.
  Future<Either<ApiException, Map<String, dynamic>>> suggestName({
    required String query,
    MangaSource source = MangaSource.mangaPoisk,
  }) async {
    return executeRequest(
      endpoint: "/titles/suggest",
      method: "GET",
      queryParameters: <String, dynamic>{
        "query": query,
        "source": source.name,
      },
    );
  }

  /// Executes a request to search for manga based on a query.
  /// - `query` - The search query string.
  /// - `source` - The source of the manga, represented by the [MangaSource] enum.
  ///
  /// Returns a map containing the search results.
  Future<Either<ApiException, Map<String, dynamic>>> search({
    required String query,
    MangaSource source = MangaSource.remanga,
  }) async {
    return executeRequest(
      endpoint: "/titles",
      method: "GET",
      queryParameters: <String, dynamic>{
        "query": query,
        "source": source.name,
      },
    );
  }

  /// Executes a global search for manga across all sources.
  /// - `query` - The search query string.
  /// - `limit` - The maximum number of results to return (default is 10).
  /// - `sortBy` - The sorting criteria for the results, represented by the [SortingEnum] enum (default is by name).
  /// - `reverse` - Whether to reverse the sorting order (default is false).
  /// 
  /// Returns a map containing the global search results.
  Future<Either<ApiException, Map<String, dynamic>>> globalSearch({
    required String query,
    int limit = 10,
    SortingEnum sortBy = SortingEnum.name,
    bool reverse = false,
  }) async {
    return executeRequest(
      endpoint: "/titles/global-search",
      method: "GET",
      queryParameters: <String, dynamic>{
        "query": query,
        "limit": limit,
        "reverse": reverse,
        "sortBy": sortBy.name,
      },
    );
  }

  /// Executes a request to get the user's manga library.
  /// - `section` - The section of the manga library to retrieve, represented by the [MangaSection] enum.
  /// - `page` - The page number for pagination (default is 1).
  /// - `perPage` - The number of items per page (default is [ApiConstants.defaultLimit]).
  /// - `sortBy` - The sorting criteria for the results, represented by the [SortingEnum] enum (default is by date).
  /// 
  /// Returns a map containing the user's manga library data.
  Future<Either<ApiException, Map<String, dynamic>>> getUserManga({
    required MangaSection section,
    int page = 1,
    int perPage = ApiConstants.defaultLimit,
    SortingEnum sortBy = SortingEnum.date,
  }) async {
    return executeRequest(
      endpoint: "/titles/me",
      method: "GET",
      queryParameters: <String, dynamic>{
        "section": section.name,
        "page": page,
        "per_page": perPage,
        "sortBy": sortBy.name,
      },
    );
  }
}
