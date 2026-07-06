import 'package:dio/dio.dart';

/// A factory for creating configured [Dio] HTTP clients.
class DioClient {
  /// Creates a [DioClient] instance.
  DioClient({
    this.baseUrl,
    this.connectTimeout = const Duration(seconds: 15),
    this.receiveTimeout = const Duration(seconds: 15),
    this.interceptors = const [],
  });

  /// The base URL prepended to all requests.
  final String? baseUrl;

  /// The maximum duration to wait while establishing a connection.
  final Duration connectTimeout;

  /// The maximum duration to wait while receiving a response.
  final Duration receiveTimeout;

  /// The interceptors applied to every request and response.
  final Iterable<Interceptor> interceptors;

  /// Creates and returns a configured [Dio] instance.
  Dio createClient() {
    final dio = Dio(
      BaseOptions(
        baseUrl: baseUrl ?? '',
        connectTimeout: connectTimeout,
        receiveTimeout: receiveTimeout,
        headers: defaultHeaders,
      ),
    );

    dio.interceptors.addAll(interceptors);

    return dio;
  }

  /// The default headers included in every request.
  Map<String, dynamic> get defaultHeaders => {
    'Content-Type': 'application/json',
  };
}
