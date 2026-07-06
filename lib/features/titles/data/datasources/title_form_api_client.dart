import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';
import 'package:shinga/features/features.dart';

part 'title_form_api_client.g.dart';

/// Retrofit client for title form endpoints (genres, categories, statuses, types, bookmarks).
@RestApi(baseUrl: 'v1/forms/titles/')
abstract class TitleFormApiClient {
  /// Creates a [TitleFormApiClient] backed by the given [Dio] instance.
  factory TitleFormApiClient(Dio dio) = _TitleFormApiClient;

  /// Fetches all available genre form options.
  @GET('/genres')
  Future<TitleGenreFormsResponseDTO> getGenreForms();

  /// Fetches all available category form options.
  @GET('/categories')
  Future<TitleCategoryFormsResponseDTO> getCategoryForms();

  /// Fetches all available publication status form options.
  @GET('/statuses')
  Future<TitleStatusFormsResponseDTO> getStatusForms();

  /// Fetches all available publication type form options.
  @GET('/types')
  Future<TitleTypeFormsResponseDTO> getTypeForms();
}
