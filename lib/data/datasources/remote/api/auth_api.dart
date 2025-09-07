import 'package:dio/dio.dart' hide Headers;
import 'package:fpdart/fpdart.dart';
import 'package:retrofit/retrofit.dart';

import '../../../models/models.dart';
import 'call_adapter.dart';

part 'auth_api.g.dart';

/// API for authentication-related operations.
@RestApi(baseUrl: 'auth', callAdapter: EitherCallAdapter)
abstract class AuthApi {
  factory AuthApi(Dio dio) = _AuthApi;

  /// Login using username and password.
  @POST('/login/access-token')
  @Headers(<String, dynamic>{
    'Content-Type': 'application/x-www-form-urlencoded',
  })
  Future<Either<HttpError, Token>> login({
    @Field('username') required String username,
    @Field('password') required String password,
  });

  /// Send a password reset email.
  @POST('/password/forgot')
  Future<Either<HttpError, MessageResponse>> forgotPassword({
    @Field('email') required String email,
  });

  /// Verify the reset code sent to email.
  @POST('/password/verify-reset-code')
  Future<Either<HttpError, MessageResponse>> verifyResetCode({
    @Field('email') required String email,
    @Field('code') required String code,
  });

  /// Reset password using email, code, and new password.
  @POST('/password/reset')
  Future<Either<HttpError, MessageResponse>> resetPassword({
    @Field('email') required String email,
    @Field('code') required String code,
    @Field('new_password') required String newPassword,
  });

  /// Sign up a new user.
  @POST('/signup')
  Future<Either<HttpError, MessageResponse>> signUp({
    @Field('username') required String username,
    @Field('email') required String email,
    @Field('password') required String password,
  });

  /// Exchange Yandex access token for application token.
  @POST('/yandex/exchange')
  Future<Either<HttpError, Token>> exchangeYandexToken({
    @Query('access_token') required String accessToken,
  });

  /// Exchange Google access token for application token.
  @POST('/google/exchange')
  Future<Either<HttpError, Token>> exchangeGoogleToken({
    @Query('access_token') required String accessToken,
  });
}
