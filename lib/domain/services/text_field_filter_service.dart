import 'package:flutter/material.dart';
import 'package:form_builder_validators/form_builder_validators.dart';

import '../../i18n/strings.g.dart';

class TextFieldFilterService {
  static FormFieldValidator<String> minNum(
    num min, {
    bool isRequired = false,
    String? errorText,
  }) {
    return FormBuilderValidators.compose([
      if (isRequired) FormBuilderValidators.required(),
      FormBuilderValidators.numeric(
        errorText: t.errors.validation.invalidNumericField,
        checkNullOrEmpty: isRequired,
      ),
      FormBuilderValidators.min(
        min,
        errorText: errorText ?? '>= $min',
        checkNullOrEmpty: isRequired,
      ),
    ]);
  }

  static FormFieldValidator<String> sliceNum(
    num min,
    num max, {
    bool isRequired = false,
    String? minErrorText,
    String? maxErrorText,
  }) {
    return FormBuilderValidators.compose([
      if (isRequired) FormBuilderValidators.required(),
      FormBuilderValidators.numeric(
        errorText: t.errors.validation.invalidNumericField,
        checkNullOrEmpty: isRequired,
      ),
      FormBuilderValidators.min(
        min,
        errorText: minErrorText ?? '>= $min',
        checkNullOrEmpty: isRequired,
      ),
      FormBuilderValidators.max(
        max,
        errorText: maxErrorText ?? '<= $max',
        checkNullOrEmpty: isRequired,
      ),
    ]);
  }

  static FormFieldValidator<String> length(
    int min,
    int max, {
    String? minErrorText,
    String? maxErrorText,
  }) {
    return FormBuilderValidators.compose([
      FormBuilderValidators.required(errorText: t.errors.validation.emptyField),
      FormBuilderValidators.minLength(
        min,
        errorText:
            minErrorText ??
            t.errors.validation.invalidFieldLength(
              comparison: t.auth.comparison.greaterOrEqual,
              length: min,
            ),
      ),
      FormBuilderValidators.maxLength(
        max,
        errorText:
            maxErrorText ??
            t.errors.validation.invalidFieldLength(
              comparison: t.auth.comparison.lessOrEqual,
              length: max,
            ),
      ),
    ]);
  }

  static FormFieldValidator<String> resetCode() {
    return FormBuilderValidators.compose([
      FormBuilderValidators.required(errorText: t.errors.validation.emptyField),
      FormBuilderValidators.equalLength(
        6,
        errorText: t.errors.validation.invalidFieldLength(
          comparison: t.auth.comparison.equal,
          length: 6,
        ),
      ),
      FormBuilderValidators.numeric(errorText: t.errors.validation.invalidNumericField),
    ]);
  }

  static FormFieldValidator<String> email({
    String? emptyErrorText,
    String? emailErrorText,
  }) {
    return FormBuilderValidators.compose([
      FormBuilderValidators.required(errorText: emptyErrorText ?? t.errors.validation.emptyField),
      FormBuilderValidators.email(errorText: emailErrorText ?? t.errors.validation.invalidEmail),
    ]);
  }

  static FormFieldValidator<String> password({
    int minLength = 8,
    int maxLength = 128,
    String? emptyErrorText,
    String? minLengthErrorText,
    String? maxLengthErrorText,
    String? invalidCharacterErrorText,
  }) {
    return FormBuilderValidators.compose([
      FormBuilderValidators.required(errorText: emptyErrorText ?? t.errors.validation.emptyField),
      FormBuilderValidators.minLength(
        minLength,
        errorText:
            minLengthErrorText ??
            t.errors.validation.invalidFieldLength(
              comparison: t.auth.comparison.greaterOrEqual,
              length: minLength,
            ),
      ),
      FormBuilderValidators.maxLength(
        maxLength,
        errorText:
            maxLengthErrorText ??
            t.errors.validation.invalidFieldLength(
              comparison: t.auth.comparison.lessOrEqual,
              length: maxLength,
            ),
      ),
      FormBuilderValidators.hasUppercaseChars(
        errorText: invalidCharacterErrorText ?? t.errors.validation.invalidPasswordCharacter,
      ),
    ]);
  }
}
