import 'package:flutter/material.dart';

/// Provides form validation methods for text fields.
class TFValidator {
  /// Validates password strength and requirements.
  ///
  /// Returns error message or null if valid.
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return "Password cannot be empty";
    } else if (value.length < 8) {
      return "Password must contain at least 8 characters";
    }
    if (!RegExp(r"^(?=.*[A-Z])(?=.*[a-z]).{8,}$").hasMatch(value)) {
      return "Password needs upper and lowercase letters";
    }
    return null;
  }

  /// Checks if a value is null or empty.
  ///
  /// Returns error message or null if valid.
  static String? checkOnNullOrEmpty(String? value) {
    if (value == null || value.isEmpty) {
      return "All fields must be filled";
    }
    return null;
  }

  /// Verifies that password and confirmation match.
  ///
  /// Returns error message or null if valid.
  static String? checkOnPasswordMatch(
    String? password,
    String? confirmPassword,
  ) {
    if (password != confirmPassword) {
      return "Passwords do not match";
    }
    return null;
  }

  /// Validates login form fields.
  ///
  /// Returns error message or null if valid.
  static String? validateLoginForm({
    required String username,
    required String password,
  }) {
    String? message = validatePassword(password);
    message ??= checkOnNullOrEmpty(username);

    return message;
  }

  /// Validates signup form fields.
  ///
  /// Returns error message or null if valid.
  static String? validateSignUpForm({
    required String username,
    required String password,
    required String confirmPassword,
  }) {
    String? message = validatePassword(password);
    message ??= checkOnPasswordMatch(password, confirmPassword);
    message ??= checkOnNullOrEmpty(username);

    return message;
  }

  /// Displays validation error in a snackbar.
  static void showValidationError(
    BuildContext context,
    String message,
  ) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }
}
