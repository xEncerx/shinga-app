part of 'password_reset_bloc.dart';

/// Base event for password reset process in the authentication flow.
sealed class PasswordResetEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

/// Step 1: request a reset code to be sent to [email].
final class PasswordResetRequested extends PasswordResetEvent {
  /// Creates a [PasswordResetRequested] event.
  PasswordResetRequested({
    required this.email,
    required this.emailLanguage,
  });

  /// The email address to send the reset code to.
  final String email;

  /// The language to use for the password reset email.
  final AppLanguage emailLanguage;

  @override
  List<Object?> get props => [email, emailLanguage];
}

/// Step 2: verify that the entered [code] is valid.
final class PasswordResetCodeSubmitted extends PasswordResetEvent {
  /// Creates a [PasswordResetCodeSubmitted] event.
  PasswordResetCodeSubmitted({required this.code});

  /// The verification code entered by the user.
  final String code;

  @override
  List<Object?> get props => [code];
}

/// Step 3: set a [newPassword] using the verified email and code.
final class PasswordResetNewPasswordSubmitted extends PasswordResetEvent {
  /// Creates a [PasswordResetNewPasswordSubmitted] event.
  PasswordResetNewPasswordSubmitted({required this.newPassword});

  /// The new password chosen by the user.
  final String newPassword;

  @override
  List<Object?> get props => [newPassword];
}
