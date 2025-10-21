import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shinga/utils/password_strength.dart';

void main() {
  group('PasswordStrength', () {
    // ==================== calculate() ====================
    group('calculate()', () {
      test('should return 0 for empty password', () {
        expect(PasswordStrength.calculate(''), 0.0);
      });
      test('should return higher score for longer passwords', () {
        final score8chars = PasswordStrength.calculate('12345678');
        final score16chars = PasswordStrength.calculate('1234567890123456');

        expect(score16chars, greaterThan(score8chars));
      });
      test('should give bonus points for uppercase letters', () {
        final scoreNoUpper = PasswordStrength.calculate('abcdefg1!');
        final scoreWithUpper = PasswordStrength.calculate('Abcdefg1!');

        expect(scoreWithUpper, greaterThan(scoreNoUpper));
      });
      test('should give bonus points for lowercase letters', () {
        final withoutLower = PasswordStrength.calculate('PASSWORD123!');
        final withLower = PasswordStrength.calculate('PASSWORd123!');

        expect(withLower, greaterThan(withoutLower));
      });
      test('should give bonus points for numbers', () {
        final withoutNumbers = PasswordStrength.calculate('Password!@#');
        final withNumbers = PasswordStrength.calculate('Password123!');

        expect(withNumbers, greaterThan(withoutNumbers));
      });

      test('should give bonus points for special characters', () {
        final withoutSpecial = PasswordStrength.calculate('Password123');
        final withSpecial = PasswordStrength.calculate('Password123!');

        expect(withSpecial, greaterThan(withoutSpecial));
      });
      test('should apply penalty for repeating characters', () {
        final diverse = PasswordStrength.calculate(r'Abcd1234!@#$');
        final repeating = PasswordStrength.calculate('Aaaa1111!!!!');

        expect(diverse, greaterThan(repeating));
      });
      test('should apply penalty for sequential characters', () {
        final normal = PasswordStrength.calculate('P@ssw0rd!XyZ');
        final sequential = PasswordStrength.calculate('qwerty123456');

        expect(normal, greaterThan(sequential));
      });
      test('should apply penalty for common patterns', () {
        final unique = PasswordStrength.calculate('MyUn1qu3P@ss');
        final common = PasswordStrength.calculate('password123');

        expect(unique, greaterThan(common));
      });
      test('should clamp score between 0 and 100', () {
        const veryComplex = r'Aa1!Bb2@Cc3#Dd4\$Ee5%Ff6^Gg7&Hh8*Ii9(Jj0)';
        final score = PasswordStrength.calculate(veryComplex);

        expect(score, lessThanOrEqualTo(100.0));
        expect(score, greaterThanOrEqualTo(0.0));
      });
    });
    // ==================== getComplexityLevel() ====================
    group('getComplexityLevel()', () {
      test('should return veryWeak for score below 20', () {
        final level = PasswordStrength.getComplexityLevel(10.0);
        expect(level, PasswordStrengthLevel.veryWeak);
      });
      test('should return weak for score between 20 and 40', () {
        final level = PasswordStrength.getComplexityLevel(30.0);
        expect(level, PasswordStrengthLevel.weak);
      });
      test('should return medium for score between 40 and 60', () {
        final level = PasswordStrength.getComplexityLevel(50.0);
        expect(level, PasswordStrengthLevel.medium);
      });
      test('should return strong for score between 60 and 80', () {
        final level = PasswordStrength.getComplexityLevel(70.0);
        expect(level, PasswordStrengthLevel.strong);
      });
      test('should return veryStrong for score between 80 and 100', () {
        final level = PasswordStrength.getComplexityLevel(90.0);
        expect(level, PasswordStrengthLevel.veryStrong);
      });
      test('should handle boundary values correctly', () {
        expect(PasswordStrength.getComplexityLevel(19.99), equals(PasswordStrengthLevel.veryWeak));
        expect(PasswordStrength.getComplexityLevel(20.0), equals(PasswordStrengthLevel.weak));
        expect(PasswordStrength.getComplexityLevel(39.99), equals(PasswordStrengthLevel.weak));
        expect(PasswordStrength.getComplexityLevel(40.0), equals(PasswordStrengthLevel.medium));
      });
    });
    // ==================== getStrengthColor() ====================
    group('getStrengthColor()', () {
      test('should return red for veryWeak strength', () {
        final color = PasswordStrength.getStrengthColor(15);
        expect(color, equals(Colors.red));
      });
      test('should return orange for weak strength', () {
        final color = PasswordStrength.getStrengthColor(30);
        expect(color, equals(Colors.orange));
      });
      test('should return yellow for medium strength', () {
        final color = PasswordStrength.getStrengthColor(50);
        expect(color, equals(Colors.yellow));
      });
      test('should return lightGreen for strong strength', () {
        final color = PasswordStrength.getStrengthColor(70);
        expect(color, equals(Colors.lightGreen));
      });
      test('should return green for veryStrong strength', () {
        final color = PasswordStrength.getStrengthColor(90);
        expect(color, equals(Colors.green));
      });
    });
  });
}
