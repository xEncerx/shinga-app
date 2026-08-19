import 'package:flutter_test/flutter_test.dart';
import 'package:shinga/core/utils/form_validator.dart';

void main() {
  const requiredError = 'required';
  const invalidError = 'invalid';

  group('FormValidator.identifier', () {
    final validator = FormValidator.identifier(
      requiredError: requiredError,
      minLengthError: 'short',
      maxLengthError: 'long',
      patternError: 'invalid username',
      emailError: 'invalid email',
    );

    test('validates username length and allowed characters', () {
      final tooLongUsername = List<String>.filled(21, 'a').join();

      expect(validator(null), requiredError);
      expect(validator('   '), requiredError);
      expect(validator(' ab '), 'short');
      expect(validator(tooLongUsername), 'long');
      expect(validator('Encer@_+-!*%'), 'invalid email');
      expect(validator('Encer+name'), 'invalid username');
      expect(validator(' abc '), isNull);
    });

    test('accepts a valid email without applying username length limits', () {
      expect(validator(' user.with.long.name@example.com '), isNull);
      expect(validator('user@invalid'), 'invalid email');
    });
  });

  group('FormValidator.username', () {
    final validator = FormValidator.username(
      requiredError: requiredError,
      minLengthError: 'short',
      maxLengthError: 'long',
      patternError: invalidError,
    );

    test('validates length before allowed characters', () {
      final tooLongUsername = List<String>.filled(21, 'a').join();

      expect(validator(''), requiredError);
      expect(validator('a.'), 'short');
      expect(validator(tooLongUsername), 'long');
      expect(validator('valid.name'), invalidError);
      expect(validator(' valid_name-1 '), isNull);
    });
  });

  group('FormValidator.password', () {
    final validator = FormValidator.password(
      requiredError: requiredError,
      passwordStrengthError: invalidError,
    );

    test('requires the configured ASCII character groups and length', () {
      final tooLongPassword = '${List<String>.filled(127, 'A').join()}a1';

      expect(validator('   '), requiredError);
      expect(validator('Password'), invalidError);
      expect(validator('password1'), invalidError);
      expect(validator('PASSWORD1'), invalidError);
      expect(validator('Passwor1'), isNull);
      expect(validator(tooLongPassword), invalidError);
    });
  });

  group('FormValidator.email', () {
    final validator = FormValidator.email(
      requiredError: requiredError,
      emailError: invalidError,
    );

    test('accepts a trimmed address with local and domain parts', () {
      expect(validator(' '), requiredError);
      expect(validator('user@example'), invalidError);
      expect(validator(' user+tag@example.com '), isNull);
    });
  });

  group('FormValidator.verificationCode', () {
    final validator = FormValidator.verificationCode(
      requiredError: requiredError,
      codeError: invalidError,
    );

    test('requires exactly six digits and uses the custom format error', () {
      expect(validator(''), requiredError);
      expect(validator('12345'), invalidError);
      expect(validator('12345a'), invalidError);
      expect(validator('123456'), isNull);
    });
  });

  group('FormValidator.url', () {
    test('requires an HTTP or HTTPS URL with a host', () {
      final validator = FormValidator.url(
        requiredError: requiredError,
        urlError: invalidError,
      );

      expect(validator(''), requiredError);
      expect(validator('example.com'), invalidError);
      expect(validator('ftp://example.com'), invalidError);
      expect(validator('https:///filter.txt'), invalidError);
      expect(validator('https://example.com:invalid/filter.txt'), invalidError);
      expect(validator('https://example.com/filter.txt'), isNull);
      expect(validator(' https://localhost:8080/filter.txt '), isNull);
    });

    test('allows an empty value when the field is optional', () {
      final validator = FormValidator.url(
        isRequired: false,
        urlError: invalidError,
      );

      expect(validator('   '), isNull);
      expect(validator('not a url'), invalidError);
    });
  });
}
