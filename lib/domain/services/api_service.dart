import 'package:dio/dio.dart';
import 'package:talker/talker.dart';
import 'package:talker_dio_logger/talker_dio_logger.dart';

import '../../core/core.dart';
import '../../data/data.dart';
import 'interceptors/interceptors.dart';

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
  final SecureStorageRepository secureStorage;

  /// Creates and configures a Dio instance with interceptors.
  Dio createDio() {
    final Dio dio = Dio(
      BaseOptions(
        baseUrl: ApiConstants.apiUrl,
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
