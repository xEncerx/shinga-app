import 'package:dio/dio.dart';
import 'package:either_dart/either.dart';

import '../../../../core/core.dart';

abstract class BaseRemoteDataSource {
  BaseRemoteDataSource(this._dio);

  final Dio _dio;

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
