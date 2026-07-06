import 'package:dio/dio.dart' hide Headers;
import 'package:retrofit/retrofit.dart';
import 'package:shinga/features/auth/auth.dart';

part 'auth_api_client.g.dart';

/// Retrofit client for authentication-related API endpoints.
@RestApi(baseUrl: 'v1/auth/')
abstract class AuthApiClient {
  /// Creates an [AuthApiClient] backed by the given [Dio] instance.
  factory AuthApiClient(Dio dio) = _AuthApiClient;

  /// Authenticates a user and returns a [TokenDTO].
  ///
  /// [identifier] is the username or email and [password] is the user's
  /// password.
  @POST('/login/access-token')
  @Headers(<String, dynamic>{
    'Content-Type': 'application/x-www-form-urlencoded',
  })
  Future<TokenDTO> login({
    @Field('username') required String identifier,
    @Field('password') required String password,
  });

  /// Registers a new user account with the given [username], [email],
  /// and [password].
  @POST('/signup')
  Future<void> signUp({
    @Field('username') required String username,
    @Field('email') required String email,
    @Field('password') required String password,
  });

  /// Requests a password reset for the user associated with the given [email].
  @POST('/password-reset/request')
  Future<void> requestPasswordReset({
    @Field('email') required String email,
    @Field('language') required String emailLanguage,
  });

  /// Verifies the password reset code sent to the user's email.
  @POST('/password-reset/verify')
  Future<void> verifyResetCode({
    @Field('email') required String email,
    @Field('code') required String code,
  });

  /// Resets the user's password using the provided [email], [code], and
  /// [newPassword].
  @POST('/password-reset/reset')
  Future<void> resetPassword({
    @Field('email') required String email,
    @Field('code') required String code,
    @Field('new_password') required String newPassword,
  });
}
