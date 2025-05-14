part of 'auth_bloc.dart';

sealed class AuthState extends Equatable {
  @override
  List<Object?> get props => [];
}

final class AuthInitial extends AuthState {}

final class AuthLoading extends AuthState {}

sealed class AuthSuccess extends AuthState {
  AuthSuccess({required this.username});

  final String username;

  @override
  List<Object?> get props => [username];
}

final class SignInSuccess extends AuthSuccess {
  SignInSuccess({
    required super.username,
    required this.token,
  });

  final String token;

  @override
  List<Object?> get props => [token];
}

final class SignUpSuccess extends AuthSuccess {
  SignUpSuccess({
    required super.username,
    required this.token,
    required this.recoveryCode,
  });

  final String token;
  final String recoveryCode;

  @override
  List<Object?> get props => [token, recoveryCode];
}

final class PasswordRecoverySuccess extends AuthState {
  PasswordRecoverySuccess({
    required this.recoveryCode,
  });

  final String recoveryCode;

  @override
  List<Object?> get props => [recoveryCode];
}

final class AuthFailure extends AuthState {
  AuthFailure({required this.errorMessage});

  final String errorMessage;

  @override
  List<Object?> get props => [errorMessage];
}
