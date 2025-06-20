import 'package:dio/dio.dart';
import 'package:either_dart/either.dart';

import '../../../../core/core.dart';

/// An abstract base class for remote data sources that handles API requests.
abstract class BaseRemoteDataSource {
  BaseRemoteDataSource(this._dio);

  final Dio _dio;

  /// Executes a request to the API with the specified parameters.
  /// - `endpoint` - The API endpoint to call.
  /// - `method` - The HTTP method to use (GET, POST, etc.).
  /// - `queryParameters` - Optional query parameters to include in the request.
  /// - `data` - Optional data to send in the request body (for POST, PUT, etc.).
  /// - `headers` - Optional headers to include in the request.
  Future<Either<ApiException, Map<String, dynamic>>> executeRequest({
    required String endpoint,
    required String method,
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? data,
    Map<String, dynamic>? headers,
  }) async {
    try {
      final Response<dynamic> response = await _dio.request(
        endpoint,
        options: Options(method: method, headers: headers),
        queryParameters: queryParameters,
        data: data,
      );

      if (response.data is Map<String, dynamic>) {
        return Right(response.data as Map<String, dynamic>);
      } else {
        return Left(
          ApiException(
            'Invalid response format. Expected JSON object.',
            response.statusCode,
          ),
        );
      }
    } on DioException catch (e) {
      String errorMessage = 'Network error occurred';

      if (e.response != null && e.response?.data != null) {
        final responseData = e.response!.data;
        if (responseData is Map<String, dynamic>) {
          if (responseData.containsKey('detail')) {
            errorMessage = responseData['detail'].toString();
          } else if (responseData.containsKey('message')) {
            errorMessage = responseData['message'].toString();
          }
        }
      }

      return Left(
        ApiException(
          errorMessage,
          e.response?.statusCode,
        ),
      );
    } catch (e) {
      return Left(
        ApiException('An unexpected error occurred: $e'),
      );
    }
  }
}
