import 'package:either_dart/either.dart';

import '../../../core/core.dart';
import '../../../data/data.dart';
import '../../enums/enums.dart';

class MangaRepository {
  MangaRepository(this._remoteDataSource);

  final MangaRemoteDataSource _remoteDataSource;

  Future<Either<ApiException, bool>> createManga({
    required Manga manga,
  }) async {
    final result = await _remoteDataSource.createManga(manga: manga);

    return result.fold(
      (error) => Left(error),
      (data) => Right(result.isLeft),
    );
  }

  Future<Either<ApiException, bool>> updateManga({
    required String mangaId,
    String currentUrl = "",
    MangaSection? section,
    DateTime? lastRead,
  }) async {
    final result = await _remoteDataSource.updateManga(
      mangaId: mangaId,
      currentUrl: currentUrl,
      section: section,
      lastRead: lastRead,
    );

    return result.fold(
      (error) => Left(error),
      (data) => Right(result.isLeft),
    );
  }

  Future<Either<ApiException, MangaResponse<String?>>> suggestName({
    required String query,
    MangaSource source = MangaSource.manga_poisk,
  }) async {
    final result = await _remoteDataSource.suggestName(
      query: query,
      source: source,
    );

    return result.fold(
      (error) => Left(error),
      (data) {
        final response = MangaResponse<String?>.fromJson(
          data,
          (item) => item! as String,
        );
        return Right(response);
      },
    );
  }

  Future<Either<ApiException, MangaResponse<Manga?>>> search({
    required String query,
    MangaSource source = MangaSource.remanga,
  }) async {
    final result = await _remoteDataSource.search(
      query: query,
      source: source,
    );

    return result.fold(
      (error) => Left(error),
      (data) {
        final response = MangaResponse<Manga?>.fromJson(
          data,
          (item) => Manga.fromJson(item! as Map<String, dynamic>),
        );
        return Right(response);
      },
    );
  }

  Future<Either<ApiException, MangaResponse<Manga?>>> globalSearch({
    required String query,
    int limit = 10,
    SortingEnum sortBy = SortingEnum.name,
    bool reverse = false,
  }) async {
    final result = await _remoteDataSource.globalSearch(
      query: query,
      limit: limit,
      sortBy: sortBy,
      reverse: reverse,
    );

    return result.fold(
      (error) => Left(error),
      (data) {
        final response = MangaResponse<Manga?>.fromJson(
          data,
          (item) => Manga.fromJson(item! as Map<String, dynamic>),
        );
        return Right(response);
      },
    );
  }

  Future<Either<ApiException, MangaResponse<Manga?>>> getUserManga({
    MangaSection section = MangaSection.any,
    int page = 1,
    int perPage = 20,
    SortingEnum sortBy = SortingEnum.date,
  }) async {
    final result = await _remoteDataSource.getUserManga(
      section: section,
      page: page,
      perPage: perPage,
      sortBy: sortBy,
    );

    return result.fold(
      (error) => Left(error),
      (data) {
        final response = MangaResponse<Manga?>.fromJson(
          data,
          (item) => Manga.fromJson(item! as Map<String, dynamic>),
        );
        return Right(response);
      },
    );
  }
}
