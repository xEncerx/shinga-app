part of 'password_reset_bloc.dart';

/// Identifies which step of the reset flow a failure occurred on.
enum PasswordResetStep {
  /// The user is requesting a reset code to be sent to their email.
  email,

  /// The user is submitting the verification code they received.
  code,

  /// The user is submitting their new password
  newPassword,
}

/// Base state for reset password process in the authentication flow.
sealed class PasswordResetState extends Equatable {
  @override
  List<Object?> get props => [];
}

/// Initial idle state.
final class PasswordResetInitial extends PasswordResetState {}

/// A request is in progress.
final class PasswordResetLoading extends PasswordResetState {}

/// Step 1 succeeded — ready to enter the verification code.
final class PasswordResetEmailSent extends PasswordResetState {
  /// Creates a [PasswordResetEmailSent] state.
  PasswordResetEmailSent({required this.email});

  /// The email address the code was sent to.
  final String email;

  @override
  List<Object?> get props => [email];
}

/// Step 2 succeeded — ready to enter the new password.
final class PasswordResetCodeVerified extends PasswordResetState {
  /// Creates a [PasswordResetCodeVerified] state.
  PasswordResetCodeVerified({required this.email, required this.code});

  /// The email address used in the flow.
  final String email;

  /// The verified reset code.
  final String code;

  @override
  List<Object?> get props => [email, code];
}

/// Step 3 succeeded — password has been reset.
final class PasswordResetSuccess extends PasswordResetState {}

/// A step failed. [step] indicates which screen should be re-shown.
final class PasswordResetFailure extends PasswordResetState {
  /// Creates a [PasswordResetFailure] state.
  PasswordResetFailure({required this.failure, required this.step});

  /// The failure returned from the repository.
  final AppFailure failure;

  /// The step at which the failure occurred.
  final PasswordResetStep step;

  @override
  List<Object?> get props => [failure, step];
}
