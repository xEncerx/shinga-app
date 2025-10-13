import 'package:dio/dio.dart' hide Headers;
import 'package:fpdart/fpdart.dart';
import 'package:retrofit/retrofit.dart';

import '../../../models/models.dart';
import 'call_adapter.dart';

part 'titles_api.g.dart';

/// API for title-related operations.
@RestApi(baseUrl: 'titles', callAdapter: EitherCallAdapter)
abstract class TitlesApi {
  factory TitlesApi(Dio dio) = _TitlesApi;

  /// Fetches a list of titles with user data.
  @GET('/search')
  Future<Either<ApiException, TitlePaginationResponse>> search(
    @Body(nullToAbsent: true) Map<String, dynamic> queries,
  );

  /// Gets recommendations based on a specific title ID.
  @GET('/{titleId}/recommendations')
  Future<Either<ApiException, TitleSearchResponse>> getRecommendations(
    @Path('titleId') String titleId,
  );
}
