import 'package:dio/dio.dart';
import 'package:either_dart/either.dart';
import 'package:talker/talker.dart';
import 'package:talker_dio_logger/talker_dio_logger.dart';

import '../../data/data.dart';
import '../core.dart';

typedef ApiResponse<T> = Either<ApiException, T>;

class ApiException implements Exception {
  ApiException(this.message, [this.statusCode]);

  final String message;
  final int? statusCode;
}

class DioClient {
  DioClient({
    required this.talker,
    required this.secureStorage,
  });

  final Talker talker;
  final SecureStorageDatasource secureStorage;

  Dio createDio() {
    final Dio dio = Dio(
      BaseOptions(
        baseUrl: ApiConstants.baseUrl,
        connectTimeout: ApiConstants.connectTimeout,
        receiveTimeout: ApiConstants.receiveTimeout,
      ),
    );

    dio.interceptors.addAll(<Interceptor>[
      TalkerDioLogger(
        talker: talker,
        settings: const TalkerDioLoggerSettings(
          printResponseData: false,
          printRequestData: false,
        ),
      ),
      AuthInterceptor(secureStorage),
      RefreshTokenInterceptor(secureStorage),
    ]);

    return dio;
  }
}
