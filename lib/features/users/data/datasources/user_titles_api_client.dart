import 'package:dio/dio.dart' hide Headers;
import 'package:retrofit/retrofit.dart';
import 'package:shinga/features/features.dart';

part 'user_titles_api_client.g.dart';

/// Retrofit client for user-related API endpoints.
@RestApi(baseUrl: 'v1/users/titles/')
abstract class UserTitlesApiClient {
  /// Creates a [UserTitlesApiClient] backed by the given [Dio] instance.
  factory UserTitlesApiClient(Dio dio) = _UserTitlesApiClient;

  /// Adds a title to the user's list with the specified bookmark.
  @PUT('/{titleId}')
  Future<void> addUserTitle(
    @Path('titleId') int titleId, {
    @Field('bookmark') required String bookmark,
  });

  /// Updates the user's data for a specific title.
  @PATCH('/{titleId}')
  Future<void> updateUserTitle({
    @Path('titleId') required int titleId,
    @Body(nullToAbsent: true) required UpdateUserTitleParamsDTO userData,
  });
}
