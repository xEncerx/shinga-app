part of 'auth_bloc.dart';

sealed class AuthState extends Equatable {
  @override
  List<Object?> get props => [];
}

final class AuthInitial extends AuthState {}

final class AuthLoading extends AuthState {}

final class AuthSuccess extends AuthState {
  AuthSuccess({this.message = ''});

  final String message;

  @override
  List<Object?> get props => [message];
}

final class AuthSignInSuccess extends AuthSuccess {
  AuthSignInSuccess({super.message});
}

final class AuthFailure extends AuthState {
  AuthFailure(this.error);

  final HttpError error;

  @override
  List<Object?> get props => [error];
}
