import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fpdart/fpdart.dart';
import 'package:oauth2_client/access_token_response.dart';
import 'package:talker_flutter/talker_flutter.dart';

import '../../../core/core.dart';
import '../../../data/data.dart';
import '../../../i18n/strings.g.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc({
    required this.secureStorageRepo,
    required this.restClient,
  }) : super(AuthInitial()) {
    on<AuthSignInRequested>(_signIn);
    on<AuthSignUpRequested>(_signUp);
    on<AuthSendRecoverCodeRequested>(_sendRecoverCode);
    on<AuthResetCodeVerifyRequested>(_verifyResetCode);
    on<AuthResetPasswordRequested>(_resetPassword);
    on<AuthSignInWithOAuthRequested>(_signInWithOAuth);
  }

  final SecureStorageRepository secureStorageRepo;
  final RestClient restClient;

  Future<void> _signIn(
    AuthSignInRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    try {
      final result = await restClient.auth.login(
        username: event.username,
        password: event.password,
      );

      await result.fold(
        (error) async => emit(AuthFailure(error)),
        (token) async {
          await secureStorageRepo.saveToken(token);
          emit(AuthSignInSuccess(message: t.auth.notify.signInSuccess));
        },
      );
    } catch (e) {
      getIt<Talker>().error(e);
      emit(AuthFailure(HttpError(detail: t.errors.somethingWentWrong)));
    }
  }

  Future<void> _signUp(
    AuthSignUpRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    try {
      final result = await restClient.auth.signUp(
        username: event.username,
        email: event.email,
        password: event.password,
      );

      await result.fold(
        (error) async => emit(AuthFailure(error)),
        (token) async {
          emit(AuthSuccess(message: t.auth.notify.signUpSuccess));
        },
      );
    } catch (e) {
      getIt<Talker>().error(e);
      emit(AuthFailure(HttpError(detail: t.errors.somethingWentWrong)));
    }
  }

  Future<void> _sendRecoverCode(
    AuthSendRecoverCodeRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    try {
      final result = await restClient.auth.forgotPassword(email: event.email);
      result.fold(
        (error) => emit(AuthFailure(error)),
        (response) => emit(AuthRecoverCodeSent()),
      );
    } catch (e) {
      getIt<Talker>().error(e);
      emit(AuthFailure(HttpError(detail: t.errors.somethingWentWrong)));
    }
  }

  Future<void> _verifyResetCode(
    AuthResetCodeVerifyRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    try {
      final result = await restClient.auth.verifyResetCode(
        email: event.email,
        code: event.code,
      );

      await result.fold(
        (error) async => emit(AuthFailure(error)),
        (response) async {
          emit(AuthRecoverCodeVerified());
        },
      );
    } catch (e) {
      getIt<Talker>().error(e);
      emit(AuthFailure(HttpError(detail: t.errors.somethingWentWrong)));
    }
  }

  Future<void> _resetPassword(
    AuthResetPasswordRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    try {
      final result = await restClient.auth.resetPassword(
        email: event.email,
        code: event.code,
        newPassword: event.newPassword,
      );

      await result.fold(
        (error) async => emit(AuthFailure(error)),
        (token) async {
          emit(
            AuthPasswordResetSuccess(
              message: t.auth.notify.resetPasswordSuccess,
            ),
          );
        },
      );
    } catch (e) {
      getIt<Talker>().error(e);
      emit(AuthFailure(HttpError(detail: t.errors.somethingWentWrong)));
    }
  }

  Future<void> _signInWithOAuth(
    AuthSignInWithOAuthRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    if (event.oAuthResponse.accessToken == null) {
      emit(AuthFailure(HttpError(detail: t.auth.errors.oAuthError)));
      return;
    }

    try {
      late final Either<HttpError, Token> result;

      switch (event.provider) {
        case OAuthProvider.Yandex:
          result = await restClient.auth.exchangeYandexToken(
            accessToken: event.oAuthResponse.accessToken!,
          );
        case OAuthProvider.Google:
          result = await restClient.auth.exchangeGoogleToken(
            accessToken: event.oAuthResponse.accessToken!,
          );
      }

      await result.fold(
        (error) async => emit(AuthFailure(error)),
        (token) async {
          await secureStorageRepo.saveToken(token);
          emit(AuthSignInSuccess(message: t.auth.notify.signInSuccess));
        },
      );
    } catch (e) {
      getIt<Talker>().error(e);
      emit(AuthFailure(HttpError(detail: t.errors.somethingWentWrong)));
    }
  }
}
