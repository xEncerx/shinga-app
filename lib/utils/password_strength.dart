import 'package:flutter/material.dart';

import '../i18n/strings.g.dart';

/// Password strength levels
enum PasswordStrengthLevel {
  veryWeak,
  weak,
  medium,
  strong,
  veryStrong;

  String get i18n {
    switch (this) {
      case PasswordStrengthLevel.veryWeak:
        return t.auth.passwordDetail.veryWeak;
      case PasswordStrengthLevel.weak:
        return t.auth.passwordDetail.weak;
      case PasswordStrengthLevel.medium:
        return t.auth.passwordDetail.medium;
      case PasswordStrengthLevel.strong:
        return t.auth.passwordDetail.strong;
      case PasswordStrengthLevel.veryStrong:
        return t.auth.passwordDetail.veryStrong;
    }
  }
}

/// Utility class for calculating password strength and providing recommendations
class PasswordStrength {
  /// Calculates the strength of a given password and returns a score between 0 and 100
  static double calculate(String password) {
    if (password.isEmpty) return 0.0;

    double score = 0.0;
    final int length = password.length;

    // Points for length
    score += length * 4;

    // Bonus points for character variety
    final hasUpperCase = RegExp(r'[A-Z]').hasMatch(password);
    final hasLowerCase = RegExp(r'[a-z]').hasMatch(password);
    final hasNumbers = RegExp(r'[0-9]').hasMatch(password);
    final hasSpecialChars = RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(password);

    if (hasUpperCase) score += 10;
    if (hasLowerCase) score += 10;
    if (hasNumbers) score += 10;
    if (hasSpecialChars) score += 15;

    // Penalties for repeating characters
    final uniqueChars = password.split('').toSet().length;
    if (length > 0) {
      final diversityRatio = uniqueChars / length;
      score *= diversityRatio;
    }

    // Penalties for sequential characters (qwerty, 12345, etc.)
    if (_hasSequentialChars(password)) {
      score *= 0.7;
    }

    // Penalties for common patterns
    if (_isCommonPattern(password)) {
      score *= 0.5;
    }

    // Clamp score between 0 and 100
    score = score.clamp(0, 100).toDouble();

    return score;
  }

  /// Check for different sequential characters
  static bool _hasSequentialChars(String password) {
    const sequentialPatterns = [
      '123456',
      '234567',
      '345678',
      '456789',
      'qwerty',
      'asdfgh',
      'zxcvbn',
      'abcdef',
      'bcdefg',
      'cdefgh',
      'defghi',
      'efghij',
      'fghijk',
      'ghijkl',
      'hijklm',
      'ijklmn',
      'jklmno',
      'klmnop',
      'lmnopq',
      'mnopqr',
      'nopqrs',
      'opqrst',
      'pqrstu',
      'qrstuv',
      'rstuvw',
      'stuvwx',
      'tuvwxy',
      'uvwxyz',
    ];

    return sequentialPatterns.any(
      (pattern) => password.toLowerCase().contains(pattern.toLowerCase()),
    );
  }

  /// Check for common password patterns
  static bool _isCommonPattern(String password) {
    const commonPatterns = [
      'password',
      '123456',
      'qwerty',
      'admin',
      'welcome',
      'letmein',
      'monkey',
      'sunshine',
      'password1',
      '123456789',
      'football',
      'baseball',
      'iloveyou',
      'princess',
      'superman',
    ];

    return commonPatterns.contains(password.toLowerCase());
  }

  /// Gets complexity level as a string
  static PasswordStrengthLevel getComplexityLevel(double score) {
    if (score < 20) return PasswordStrengthLevel.veryWeak;
    if (score < 40) return PasswordStrengthLevel.weak;
    if (score < 60) return PasswordStrengthLevel.medium;
    if (score < 80) return PasswordStrengthLevel.strong;
    return PasswordStrengthLevel.veryStrong;
  }

  /// Gets color based on strength level
  static Color getStrengthColor(double strength) {
    final strengthEnum = getComplexityLevel(strength);

    switch (strengthEnum) {
      case PasswordStrengthLevel.veryWeak:
        return Colors.red;
      case PasswordStrengthLevel.weak:
        return Colors.orange;
      case PasswordStrengthLevel.medium:
        return Colors.yellow;
      case PasswordStrengthLevel.strong:
        return Colors.lightGreen;
      case PasswordStrengthLevel.veryStrong:
        return Colors.green;
    }
  }
}
