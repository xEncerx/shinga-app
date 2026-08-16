import 'package:flutter/material.dart';
import 'package:shinga/i18n/strings.g.dart';

/// A collection of static form field validators for common input types.
class FormValidator {
  static final RegExp _emailPattern = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');
  static final RegExp _passwordLowercasePattern = RegExp('[a-z]');
  static final RegExp _passwordNumberPattern = RegExp('[0-9]');
  static final RegExp _passwordUppercasePattern = RegExp('[A-Z]');
  static final RegExp _usernamePattern = RegExp(r'^[a-zA-Z0-9_-]+$');
  static final RegExp _verificationCodePattern = RegExp(r'^\d{6}$');
  static final RegExp _whitespacePattern = RegExp(r'\s');

  static bool _isValidHttpUrl(String input) {
    if (input.length > 2083 || _whitespacePattern.hasMatch(input)) return false;

    final uri = Uri.tryParse(input);
    if (uri == null ||
        (uri.scheme != 'http' && uri.scheme != 'https') ||
        !uri.hasAuthority ||
        uri.host.isEmpty) {
      return false;
    }

    try {
      return !uri.hasPort || (uri.port >= 1 && uri.port <= 65535);
    } on FormatException {
      return false;
    }
  }

  /// Returns a validator for username or email identifier fields.
  ///
  /// Applies email validation when the value contains `@`; otherwise applies
  /// the same length and character rules as [username].
  static FormFieldValidator<String> identifier({
    String? requiredError,
    String? minLengthError,
    String? maxLengthError,
    String? patternError,
    String? emailError,
  }) {
    return (value) {
      final input = value?.trim();
      if (input == null || input.isEmpty) {
        return requiredError ?? t.auth.validation.fieldRequired;
      }
      if (input.contains('@')) {
        return _emailPattern.hasMatch(input) ? null : emailError ?? t.auth.validation.invalidEmail;
      }
      if (input.length < 3) {
        return minLengthError ?? t.auth.validation.minLength(min: 3);
      }
      if (input.length > 20) {
        return maxLengthError ?? t.auth.validation.maxLength(max: 20);
      }
      if (!_usernamePattern.hasMatch(input)) {
        return patternError ?? t.auth.validation.invalidUsername;
      }
      return null;
    };
  }

  /// Returns a validator for username fields.
  ///
  /// Validates that the field is non-empty, has a length between 3 and 20
  /// characters, and only contains letters, numbers, underscores, or hyphens.
  static FormFieldValidator<String> username({
    String? requiredError,
    String? minLengthError,
    String? maxLengthError,
    String? patternError,
  }) {
    return (value) {
      final input = value?.trim();
      if (input == null || input.isEmpty) {
        return requiredError ?? t.auth.validation.fieldRequired;
      }
      if (input.length < 3) {
        return minLengthError ?? t.auth.validation.minLength(min: 3);
      }
      if (input.length > 20) {
        return maxLengthError ?? t.auth.validation.maxLength(max: 20);
      }
      if (!_usernamePattern.hasMatch(input)) {
        return patternError ?? t.auth.validation.invalidUsername;
      }
      return null;
    };
  }

  /// Returns a validator for password fields.
  ///
  /// Validates that the field is non-empty and meets password strength
  /// requirements (min 8 characters, at least one uppercase, one lowercase,
  /// and one digit; max 128 characters).
  static FormFieldValidator<String> password({
    String? requiredError,
    String? passwordStrengthError,
  }) {
    return (value) {
      if (value == null || value.trim().isEmpty) {
        return requiredError ?? t.auth.validation.fieldRequired;
      }
      final isStrong =
          value.length >= 8 &&
          value.length <= 128 &&
          _passwordUppercasePattern.hasMatch(value) &&
          _passwordLowercasePattern.hasMatch(value) &&
          _passwordNumberPattern.hasMatch(value);
      return isStrong ? null : passwordStrengthError ?? t.auth.validation.passwordStrength;
    };
  }

  /// Returns a validator for email fields.
  ///
  /// Validates that the field is non-empty and contains a valid email address.
  static FormFieldValidator<String> email({
    String? requiredError,
    String? emailError,
  }) {
    return (value) {
      final input = value?.trim();
      if (input == null || input.isEmpty) {
        return requiredError ?? t.auth.validation.fieldRequired;
      }
      return _emailPattern.hasMatch(input) ? null : emailError ?? t.auth.validation.invalidEmail;
    };
  }

  /// Returns a validator for verification code fields.
  ///
  /// Validates that the field is non-empty and contains exactly 6 digits.
  static FormFieldValidator<String> verificationCode({
    String? requiredError,
    String? codeError,
  }) {
    return (value) {
      if (value == null || value.trim().isEmpty) {
        return requiredError ?? t.auth.validation.fieldRequired;
      }
      return _verificationCodePattern.hasMatch(value)
          ? null
          : codeError ?? t.auth.validation.invalidVerificationCode;
    };
  }

  /// Returns a validator for URL fields.
  ///
  /// Validates required values and accepts only HTTP or HTTPS URLs with a host.
  static FormFieldValidator<String> url({
    bool isRequired = true,
    String? requiredError,
    String? urlError,
  }) {
    return (value) {
      final input = value?.trim();
      if (input == null || input.isEmpty) {
        return isRequired ? requiredError ?? t.auth.validation.fieldRequired : null;
      }

      return _isValidHttpUrl(input) ? null : urlError ?? t.auth.validation.invalidUrl;
    };
  }
}
