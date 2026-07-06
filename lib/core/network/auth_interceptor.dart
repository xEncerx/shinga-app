import 'package:dio/dio.dart';
import 'package:shinga/domain/repositories/repositories.dart';

/// A Dio interceptor that attaches the bearer token to outgoing requests
/// and handles session cleanup on 401/403 responses.
class AuthInterceptor extends Interceptor {
  /// Creates an [AuthInterceptor] with the given [_tokenRepository]
  /// and [_sessionRepository].
  AuthInterceptor(TokenRepository tokenRepository, SessionRepository sessionRepository)
    : _tokenRepository = tokenRepository,
      _sessionRepository = sessionRepository;

  /// The repository used to read and delete the stored access token.
  final TokenRepository _tokenRepository;

  /// The repository used to clear the current user session.
  final SessionRepository _sessionRepository;

  /// Attaches the `Authorization: Bearer <token>` header when a token
  /// is available.
  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await _tokenRepository.getToken();
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  /// Clears the stored token and session on 401, and clears the session
  /// on 403, then forwards the error.
  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    if (err.response?.statusCode == 401) {
      await _tokenRepository.deleteToken();
      await _sessionRepository.clearSession();
    }
    if (err.response?.statusCode == 403) {
      await _sessionRepository.clearSession();
    }
    handler.next(err);
  }
}
