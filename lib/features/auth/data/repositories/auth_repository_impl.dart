import 'package:fpdart/fpdart.dart';
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
  Future<Either<AppFailure, Unit>> login({
    required String identifier,
    required String password,
  }) async {
    final loginResult = await ExceptionMapper.guard(() async {
      final loginResponse = await _authApiClient.login(
        identifier: identifier,
        password: password,
      );
      await _tokenRepository.saveToken(loginResponse.accessToken);
      return unit;
    });

    if (loginResult.isLeft()) return loginResult;
    return _fetchAndSaveSession();
  }

  @override
  Future<Either<AppFailure, Unit>> logout() async {
    return ExceptionMapper.guard(() async {
      await _tokenRepository.deleteToken();
      await _sessionRepository.clearSession();

      return unit;
    });
  }

  @override
  Future<Either<AppFailure, Unit>> signUp({
    required String username,
    required String email,
    required String password,
  }) {
    return ExceptionMapper.guard(() async {
      await _authApiClient.signUp(
        username: username,
        email: email,
        password: password,
      );

      return unit;
    });
  }

  @override
  Future<Either<AppFailure, Unit>> requestPasswordReset({
    required String email,
    required AppLanguage emailLanguage,
  }) {
    return ExceptionMapper.guard(() async {
      await _authApiClient.requestPasswordReset(
        email: email,
        emailLanguage: emailLanguage.name,
      );

      return unit;
    });
  }

  @override
  Future<Either<AppFailure, Unit>> verifyResetCode({
    required String email,
    required String code,
  }) {
    return ExceptionMapper.guard(() async {
      await _authApiClient.verifyResetCode(
        email: email,
        code: code,
      );

      return unit;
    });
  }

  @override
  Future<Either<AppFailure, Unit>> resetPassword({
    required String email,
    required String code,
    required String newPassword,
  }) {
    return ExceptionMapper.guard(() async {
      await _authApiClient.resetPassword(
        email: email,
        code: code,
        newPassword: newPassword,
      );

      return unit;
    });
  }

  @override
  Future<Either<AppFailure, Unit>> refreshSession() async {
    return _fetchAndSaveSession();
  }

  Future<Either<AppFailure, Unit>> _fetchAndSaveSession() async {
    final result = await _userRepository.getCurrentUser();
    return result.fold(
      left,
      (user) async {
        await _sessionRepository.saveSession(Session(user: user));
        return right(unit);
      },
    );
  }
}
