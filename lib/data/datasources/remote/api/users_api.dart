import 'package:dio/dio.dart';
import 'package:fpdart/fpdart.dart';
import 'package:retrofit/retrofit.dart';

import '../../../models/models.dart';
import 'call_adapter.dart';

part 'users_api.g.dart';

/// API for user-related operations.
@RestApi(baseUrl: 'users', callAdapter: EitherCallAdapter)
abstract class UsersApi {
  factory UsersApi(Dio dio) = _UsersApi;

  /// Fetches the current user's data.
  @GET('/me')
  Future<Either<ApiException, UserData>> getMe();

  /// Fetches the current user's profile.
  @POST('/me/titles')
  Future<Either<ApiException, TitlePaginationResponse>> getMyTitles(
    @Body(nullToAbsent: true) Map<String, dynamic> queries,
  );

  /// Updates a title in the user's list.
  @PUT('/me/titles/update')
  Future<Either<ApiException, MessageResponse>> updateTitle({
    @Field('title_id') required String titleId,
    @Field('user_rating') int? userRating,
    @Field('current_url') String? currentUrl,
    @Field('bookmark') String? bookmark,
  });

  /// Fetches the current user's votes.
  @GET('/me/votes')
  Future<Either<ApiException, UserVotes>> getMyVotes();

  /// Updates the current user's profile data.
  @PATCH('/me/update')
  Future<Either<ApiException, MessageResponse>> updateProfile({
    @Field('username') String? username,
    @Field('description') String? description,
  });
}
