import 'package:dio/dio.dart' hide Headers;
import 'package:retrofit/retrofit.dart';
import 'package:shinga/features/features.dart';

part 'user_api_client.g.dart';

/// Retrofit client for user-related API endpoints.
@RestApi(baseUrl: 'v1/users/')
abstract class UserApiClient {
  /// Creates a [UserApiClient] backed by the given [Dio] instance.
  factory UserApiClient(Dio dio) = _UserApiClient;

  /// Fetches the currently authenticated user's profile.
  @GET('/me')
  Future<UserDTO> getCurrentUser();

  /// Fetches aggregated statistics for the currently authenticated user.
  @GET('/statistics')
  Future<UserStatisticsDTO> getStatistics();
}
