import 'package:dio/dio.dart';
import 'package:either_dart/either.dart';
import 'package:talker/talker.dart';
import 'package:talker_dio_logger/talker_dio_logger.dart';

import '../../data/data.dart';
import '../core.dart';

/// Type alias for API responses using Either for error handling.
typedef ApiResponse<T> = Either<ApiException, T>;

/// Custom exception for API-related errors.
class ApiException implements Exception {
  /// Creates an API exception with a message and optional status code.
  ApiException(this.message, [this.statusCode]);

  /// Error message.
  final String message;

  /// HTTP status code if applicable.
  final int? statusCode;
}

/// Creates and configures Dio HTTP client.
class DioClient {
  /// Creates a Dio client with logging and auth capabilities.
  DioClient({
    required this.talker,
    required this.secureStorage,
  });

  /// Logging service.
  final Talker talker;

  /// Secure storage for auth tokens.
  final SecureStorageDatasource secureStorage;

  /// Creates and configures a Dio instance with interceptors.
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
