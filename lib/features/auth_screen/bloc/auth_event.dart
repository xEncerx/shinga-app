part of 'auth_bloc.dart';

sealed class AuthEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

final class AuthSignUpRequested extends AuthEvent {
  AuthSignUpRequested({
    required this.username,
    required this.email,
    required this.password,
  });

  final String username;
  final String email;
  final String password;

  @override
  List<Object?> get props => [username, email, password];
}

final class AuthSignInRequested extends AuthEvent {
  AuthSignInRequested({
    required this.username,
    required this.password,
  });

  final String username;
  final String password;

  @override
  List<Object?> get props => [username, password];
}

final class AuthSendRecoverCodeRequested extends AuthEvent {
  AuthSendRecoverCodeRequested({required this.email});

  final String email;

  @override
  List<Object?> get props => [email];
}

final class AuthResetCodeVerifyRequested extends AuthEvent {
  AuthResetCodeVerifyRequested({
    required this.code,
    required this.email,
  });

  final String code;
  final String email;

  @override
  List<Object?> get props => [code, email];
}

final class AuthResetPasswordRequested extends AuthEvent {
  AuthResetPasswordRequested({
    required this.code,
    required this.email,
    required this.newPassword,
  });

  final String code;
  final String email;
  final String newPassword;

  @override
  List<Object?> get props => [code, email, newPassword];
}

final class AuthSignInWithOAuthRequested extends AuthEvent {
  AuthSignInWithOAuthRequested({required this.oAuthResponse, required this.provider});

  final AccessTokenResponse oAuthResponse;
  final OAuthProvider provider;

  @override
  List<Object?> get props => [oAuthResponse, provider];
}
