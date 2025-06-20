import 'package:dio/dio.dart';
import 'package:talker/talker.dart';

import '../../../data/data.dart';
import '../../core.dart';

/// Interceptor that adds authentication token to requests.
class AuthInterceptor extends Interceptor {
  /// Creates an auth interceptor with secure storage.
  AuthInterceptor(this._secureStorage);

  /// Storage for authentication tokens.
  final SecureStorageDatasource _secureStorage;

  /// Adds authorization header to outgoing requests if token exists.
  @override
  Future<void> onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    final token = await _secureStorage.getToken();
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }
}

/// Interceptor to handle token expiration and unauthorized access.
class RefreshTokenInterceptor extends QueuedInterceptor {
  /// Creates a refresh token interceptor with secure storage.
  RefreshTokenInterceptor(this._secureStorage);

  /// Storage for authentication tokens.
  final SecureStorageDatasource _secureStorage;

  /// Handles 401 errors by logging out and redirecting to auth screen.
  @override
  Future<void> onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == 401) {
      await _secureStorage.deleteToken();

      getIt<AppRouter>().replaceAll([const AuthRoute()]);
    }

    getIt<Talker>().error(err.message);
    super.onError(err, handler);
  }
}
