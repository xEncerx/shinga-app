import 'package:either_dart/either.dart';

import '../../../../core/core.dart';
import '../../../../domain/domain.dart';
import '../../../data.dart';

class MangaRemoteDataSource extends BaseRemoteDataSource {
  MangaRemoteDataSource(super.dio);

  Future<Either<ApiException, Map<String, dynamic>>> createManga({
    required Manga manga,
  }) async {
    return executeRequest(
      endpoint: "/titles/create",
      method: "POST",
      data: manga.toJson(),
    );
  }

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

  Future<Either<ApiException, Map<String, dynamic>>> suggestName({
    required String query,
    MangaSource source = MangaSource.manga_poisk,
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

  Future<Either<ApiException, Map<String, dynamic>>> getUserManga({
    required MangaSection section,
    int page = 1,
    int perPage = 20,
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
