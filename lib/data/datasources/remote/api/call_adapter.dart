import 'package:dio/dio.dart';
import 'package:fpdart/fpdart.dart';
import 'package:retrofit/retrofit.dart';

import '../../../models/exceptions/exceptions.dart';

class EitherCallAdapter<T> extends CallAdapter<Future<T>, Future<Either<ApiException, T>>> {
  @override
  Future<Either<ApiException, T>> adapt(Future<T> Function() call) async {
    try {
      final response = await call();
      return Right(response);
    } on DioException catch (e) {
      final statusCode = e.response?.statusCode ?? 500;
      late final ApiException error;

      if (statusCode == 500) {
        error = ApiException(
          statusCode: statusCode,
          error: 'InternalServerError',
          detail: e.message ?? 'Internal Server Error',
        );
      } else {
        error = e.response?.data != null
            ? ApiException.fromJson(e.response!.data as Map<String, dynamic>)
            : ApiException(
                statusCode: statusCode,
                error: 'UnknownError',
                detail: e.message ?? 'Unknown error',
              );
      }
      return Left(error);
    }
  }
}
