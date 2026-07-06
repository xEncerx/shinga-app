part of 'login_cubit.dart';

/// Base state for login process in the authentication flow.
sealed class LoginState extends Equatable {
  @override
  List<Object?> get props => [];
}

/// Initial idle state.
final class LoginInitial extends LoginState {}

/// Login request is in progress.
final class LoginLoading extends LoginState {}

/// Login succeeded. Bloc will handle navigation via session stream.
final class LoginSuccess extends LoginState {}

/// Login failed with a [failure].
final class LoginFailure extends LoginState {
  /// Creates a [LoginFailure] state.
  LoginFailure(this.failure);

  /// The failure returned from the repository.
  final AppFailure failure;

  @override
  List<Object?> get props => [failure];
}
