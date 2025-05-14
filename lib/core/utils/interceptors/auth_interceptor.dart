import 'package:dio/dio.dart';
import 'package:talker/talker.dart';

import '../../../data/data.dart';
import '../../core.dart';

class AuthInterceptor extends Interceptor {
  AuthInterceptor(this._secureStorage);

  final SecureStorageDatasource _secureStorage;

  @override
  Future<void> onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    final token = await _secureStorage.getToken();
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }
}

class RefreshTokenInterceptor extends QueuedInterceptor {
  RefreshTokenInterceptor(this._secureStorage);

  final SecureStorageDatasource _secureStorage;

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
