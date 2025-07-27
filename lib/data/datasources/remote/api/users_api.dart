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
  Future<Either<HttpError, UserData>> getMe();

  /// Fetches the current user's profile.
  @GET('/me/titles')
  Future<Either<HttpError, TitlePaginationResponse>> getMyTitles({
    @Field('page') required int page,
    @Field('per_page') required int perPage,
    @Field('bookmark') String? bookmark,
  });

  @PUT('/me/titles/update')
  Future<Either<HttpError, MessageResponse>> updateTitle({
    @Field('title_id') required String titleId,
    @Field('user_rating') int? userRating,
    @Field('current_url') String? currentUrl,
    @Field('bookmark') String? bookmark,
  });

  /// Fetches the current user's votes.
  @GET('/me/votes')
  Future<Either<HttpError, UserVotes>> getMyVotes();
}
