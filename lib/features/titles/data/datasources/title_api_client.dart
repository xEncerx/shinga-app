import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';
import 'package:shinga/features/features.dart';

part 'title_api_client.g.dart';

/// Retrofit client for title-related API endpoints.
@RestApi(baseUrl: 'v1/titles/')
abstract class TitleApiClient {
  /// Creates a [TitleApiClient] backed by the given [Dio] instance.
  factory TitleApiClient(Dio dio) = _TitleApiClient;

  /// Fetches detailed information about a title by its ID.
  @GET('/{id}')
  Future<TitleContentDataDTO> getTitle(@Path() String id);

  /// Searches for titles based on various optional filters, sorting and pagination parameters.
  @POST('/search')
  Future<TitleSearchDataDTO> searchTitles({
    @Field('query') String? query,
    @Field('type') String? type,
    @Field('status') String? status,
    @Field('genres') List<String>? genres,
    @Field('categories') List<String>? categories,
    @Field('bookmark') String? bookmark,
    @Field('min_rating') int? minRating,
    @Field('max_rating') int? maxRating,
    @Field('min_chapters') int? minChapters,
    @Field('max_chapters') int? maxChapters,
    @Field('sort_by') String? sortBy,
    @Field('sort_order') String? sortOrder,
    @Field('page') int? page,
    @Field('page_size') int? pageSize,
  });
}
