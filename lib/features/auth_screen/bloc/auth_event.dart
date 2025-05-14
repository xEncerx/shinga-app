part of 'auth_bloc.dart';

sealed class AuthEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

final class SignInEvent extends AuthEvent {
  SignInEvent({
    required this.username,
    required this.password,
  });

  final String username;
  final String password;

  @override
  List<Object?> get props => [
        username,
        password,
      ];
}

final class SignUpEvent extends AuthEvent {
  SignUpEvent({
    required this.username,
    required this.password,
  });

  final String username;
  final String password;

  @override
  List<Object?> get props => [
        username,
        password,
      ];
}

final class RecoverPasswordEvent extends AuthEvent {
  RecoverPasswordEvent({
    required this.username,
    required this.newPassword,
    required this.recoveryCode,
  });

  final String username;
  final String newPassword;
  final String recoveryCode;

  @override
  List<Object?> get props => [
        username,
        newPassword,
        recoveryCode,
      ];
}
