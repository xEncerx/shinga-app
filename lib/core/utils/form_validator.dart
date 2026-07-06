import 'package:flutter/material.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:shinga/i18n/strings.g.dart';

/// A collection of static form field validators for common input types.
class FormValidator {
  /// Returns a validator for identifier fields (e.g. username, email).
  ///
  /// Validates that the field is non-empty and has a minimum length of 3
  /// characters.
  static FormFieldValidator<String> identifier({
    String? requiredError,
    String? minLengthError,
  }) {
    return FormBuilderValidators.compose([
      FormBuilderValidators.required(
        errorText: requiredError ?? t.auth.validation.fieldRequired,
      ),
      FormBuilderValidators.minLength(
        3,
        errorText: minLengthError ?? t.auth.validation.minLength(min: 3),
      ),
    ]);
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
    return FormBuilderValidators.compose([
      FormBuilderValidators.required(
        errorText: requiredError ?? t.auth.validation.fieldRequired,
      ),
      FormBuilderValidators.minLength(
        3,
        errorText: minLengthError ?? t.auth.validation.minLength(min: 3),
      ),
      FormBuilderValidators.maxLength(
        20,
        errorText: maxLengthError ?? t.auth.validation.maxLength(max: 20),
      ),
      FormBuilderValidators.match(
        RegExp(r'^[a-zA-Z0-9_-]+$'),
        errorText: patternError ?? t.auth.validation.invalidUsername,
      ),
    ]);
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
    return FormBuilderValidators.compose([
      FormBuilderValidators.required(
        errorText: requiredError ?? t.auth.validation.fieldRequired,
      ),
      FormBuilderValidators.password(
        maxLength: 128,
        minSpecialCharCount: 0,
        errorText: passwordStrengthError ?? t.auth.validation.passwordStrength,
      ),
    ]);
  }

  /// Returns a validator for email fields.
  ///
  /// Validates that the field is non-empty and contains a valid email address.
  static FormFieldValidator<String> email({
    String? requiredError,
    String? emailError,
  }) {
    return FormBuilderValidators.compose([
      FormBuilderValidators.required(
        errorText: requiredError ?? t.auth.validation.fieldRequired,
      ),
      FormBuilderValidators.email(
        errorText: emailError ?? t.auth.validation.invalidEmail,
      ),
    ]);
  }

  /// Returns a validator for verification code fields.
  ///
  /// Validates that the field is non-empty and contains exactly 6 digits.
  static FormFieldValidator<String> verificationCode({
    String? requiredError,
    String? codeError,
  }) {
    return FormBuilderValidators.compose([
      FormBuilderValidators.required(
        errorText: requiredError ?? t.auth.validation.fieldRequired,
      ),
      FormBuilderValidators.match(RegExp(r'^\d{6}$')),
    ]);
  }

  /// Returns a validator for URL fields.
  ///
  /// Validates that the field is non-empty and is a valid URL starting with http/https.
  static FormFieldValidator<String> url({
    String? requiredError,
    String? urlError,
  }) {
    return FormBuilderValidators.compose([
      FormBuilderValidators.required(
        errorText: requiredError ?? t.auth.validation.fieldRequired,
      ),
      FormBuilderValidators.url(
        protocols: ['http', 'https'],
        requireProtocol: true,
        errorText: urlError ?? t.auth.validation.invalidUrl,
      ),
    ]);
  }
}
