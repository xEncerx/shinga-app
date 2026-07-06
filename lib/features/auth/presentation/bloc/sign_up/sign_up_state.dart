part of 'sign_up_cubit.dart';

/// Base state for sign up process in the authentication flow.
sealed class SignUpState extends Equatable {
  @override
  List<Object?> get props => [];
}

/// Initial idle state.
final class SignUpInitial extends SignUpState {}

/// Registration request is in progress.
final class SignUpLoading extends SignUpState {}

/// Registration succeeded.
final class SignUpSuccess extends SignUpState {}

/// Registration failed with a [failure].
final class SignUpFailure extends SignUpState {
  /// Creates a [SignUpFailure] state.
  SignUpFailure(this.failure);

  /// The failure returned from the repository.
  final AppFailure failure;

  @override
  List<Object?> get props => [failure];
}
