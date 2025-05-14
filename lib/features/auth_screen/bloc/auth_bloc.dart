import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';

import '../../../data/data.dart';
import '../../../domain/domain.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc() : super(AuthInitial()) {
    on<SignInEvent>(
      (event, emit) async {
        emit(AuthLoading());

        final result = await _getIt<UserRepository>().login(
          username: event.username,
          password: event.password,
        );

        if (result.isLeft) {
          emit(
            AuthFailure(
              errorMessage: result.left.message,
            ),
          );
        } else {
          final Token token = result.right;
          await _getIt<SecureStorageDatasource>().saveToken(token);
          emit(
            SignInSuccess(
              token: token.accessToken,
              username: event.username,
            ),
          );
        }
      },
    );

    on<SignUpEvent>(
      (event, emit) async {
        emit(AuthLoading());

        final signUpResult = await _getIt<UserRepository>().signUp(
          username: event.username,
          password: event.password,
        );

        if (signUpResult.isLeft) {
          emit(
            AuthFailure(
              errorMessage: signUpResult.left.message,
            ),
          );
          return;
        }

        final String recoveryCode = signUpResult.right.recoveryCode;
        final loginResult = await _getIt<UserRepository>().login(
          username: event.username,
          password: event.password,
        );

        if (loginResult.isLeft) {
          emit(
            AuthFailure(
              errorMessage: loginResult.left.message,
            ),
          );
          return;
        }

        final Token token = loginResult.right;

        emit(
          SignUpSuccess(
            username: event.username,
            token: token.accessToken,
            recoveryCode: recoveryCode,
          ),
        );
      },
    );

    on<RecoverPasswordEvent>(
      (event, emit) async {
        emit(AuthLoading());

        final result = await _getIt<UserRepository>().recoverPassword(
          username: event.username,
          newPassword: event.newPassword,
          recoveryCode: event.recoveryCode,
        );

        if (result.isLeft) {
          emit(
            AuthFailure(
              errorMessage: result.left.message,
            ),
          );
        } else {
          emit(
            PasswordRecoverySuccess(
              recoveryCode: result.right.recoveryCode,
            ),
          );
        }
      },
    );
  }

  static final _getIt = GetIt.I;
}
