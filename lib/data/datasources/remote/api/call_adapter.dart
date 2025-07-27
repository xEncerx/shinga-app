import 'package:dio/dio.dart';
import 'package:fpdart/fpdart.dart';
import 'package:retrofit/retrofit.dart';

import '../../../models/errors/errors.dart';

class EitherCallAdapter<T> extends CallAdapter<Future<T>, Future<Either<HttpError, T>>> {
  @override
  Future<Either<HttpError, T>> adapt(Future<T> Function() call) async {
    try {
      final response = await call();
      return Right(response);
    } on DioException catch (e) {
      final statusCode = e.response?.statusCode ?? 500;
      late final HttpError error;

      if (statusCode == 500){
        error = HttpError(
          statusCode: statusCode,
          error: "InternalServerError",
          detail: e.message ?? 'Internal Server Error',
        );
      } else{
        error = e.response?.data != null
          ? HttpError.fromJson(e.response!.data as Map<String, dynamic>)
          : HttpError(
              statusCode: statusCode,
              error: "UnknownError",
              detail: e.message ?? 'Unknown error',
            );
      }
      return Left(error);
    }
  }
}
