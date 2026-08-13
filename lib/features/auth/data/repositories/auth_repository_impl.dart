import 'package:shinga/core/types/types.dart';
import 'package:shinga/data/data.dart';
import 'package:shinga/domain/domain.dart';
import 'package:shinga/features/features.dart';

/// Concrete implementation of [AuthRepository].
class AuthRepositoryImpl implements AuthRepository {
  /// Creates an [AuthRepositoryImpl] instance.
  const AuthRepositoryImpl({
    required this._authApiClient,
    required this._userRepository,
    required this._tokenRepository,
    required this._sessionRepository,
  });

  /// The client used to call auth-related API endpoints.
  final AuthApiClient _authApiClient;

  /// The client used to fetch user profile data.
  final UserRepository _userRepository;

  /// Handles persistence of the access token.
  final TokenRepository _tokenRepository;

  /// Handles persistence of the current user session.
  final SessionRepository _sessionRepository;

  @override
  Future<Either<AppFailure, void>> login({
    required String identifier,
    required String password,
  }) async {
    final loginResult = await ExceptionMapper.guardVoid(() async {
      final loginResponse = await _authApiClient.login(
        identifier: identifier,
        password: password,
      );
      await _tokenRepository.saveToken(loginResponse.accessToken);
    });

    if (loginResult.isLeft) return loginResult;
    return _fetchAndSaveSession();
  }

  @override
  Future<Either<AppFailure, void>> logout() async {
    return ExceptionMapper.guardVoid(() async {
      await _tokenRepository.deleteToken();
      await _sessionRepository.clearSession();
    });
  }

  @override
  Future<Either<AppFailure, void>> signUp({
    required String username,
    required String email,
    required String password,
  }) {
    return ExceptionMapper.guardVoid(() async {
      await _authApiClient.signUp(
        username: username,
        email: email,
        password: password,
      );
    });
  }

  @override
  Future<Either<AppFailure, void>> requestPasswordReset({
    required String email,
    required AppLanguage emailLanguage,
  }) {
    return ExceptionMapper.guardVoid(() async {
      await _authApiClient.requestPasswordReset(
        email: email,
        emailLanguage: emailLanguage.name,
      );
    });
  }

  @override
  Future<Either<AppFailure, void>> verifyResetCode({
    required String email,
    required String code,
  }) {
    return ExceptionMapper.guardVoid(() async {
      await _authApiClient.verifyResetCode(
        email: email,
        code: code,
      );
    });
  }

  @override
  Future<Either<AppFailure, void>> resetPassword({
    required String email,
    required String code,
    required String newPassword,
  }) {
    return ExceptionMapper.guardVoid(() async {
      await _authApiClient.resetPassword(
        email: email,
        code: code,
        newPassword: newPassword,
      );
    });
  }

  @override
  Future<Either<AppFailure, void>> refreshSession() async {
    return _fetchAndSaveSession();
  }

  Future<Either<AppFailure, void>> _fetchAndSaveSession() async {
    final result = await _userRepository.getCurrentUser();
    return result.fold<Future<Either<AppFailure, void>>>(
      (failure) async => Left(failure),
      (user) => ExceptionMapper.guardVoid(
        () => _sessionRepository.saveSession(Session(user: user)),
      ),
    );
  }
}
