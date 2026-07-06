---
name: flutter-testing-guide
description: Write unit and integration tests using mocktail, bloc_test, and flutter_test. Use when creating new logic or ensuring regression safety.
---
# Testing Guide (Unit, BLoC, Integration)

## Contents
- [Testing Principles](#testing-principles)
- [Unit Testing & Mocking](#unit-testing--mocking)
- [Testing BLoC / Cubit](#testing-bloc--cubit)
- [Integration Testing](#integration-testing)
- [Execution & Coverage](#execution--coverage)

## Testing Principles
*   **AAA Pattern:** Organize tests into `Arrange` (setup mocks, data), `Act` (execute method), `Assert` (verify state and interactions).
*   **Naming:** Use clear test variables: `inputX`, `mockX`, `expectedX`.
*   **Suffixes:** All test files must end with `_test.dart` and mirror the `lib` folder structure inside the `test` directory.

## Unit Testing & Mocking
*   Use `package:mocktail` for mocking dependencies. It does NOT require code generation.
*   Register fallback values in `setUpAll` if mocking methods that take custom classes or types as arguments.
*   Use `verify` to check interactions.

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockUserRepository extends Mock implements UserRepository {}

void main() {
  group('UserService', () {
    late MockUserRepository mockRepo;
    late UserService service;

    setUp(() {
      mockRepo = MockUserRepository();
      service = UserService(mockRepo);
    });

    test('should return user when repo succeeds', () async {
      // Arrange
      when(() => mockRepo.getUser(any())).thenAnswer((_) async => Right(testUser));
      
      // Act
      final result = await service.fetchUser('123');
      
      // Assert
      expect(result.isRight(), isTrue);
      verify(() => mockRepo.getUser('123')).called(1);
    });
  });
}
```

## Testing BLoC / Cubit
*   Use `package:bloc_test` for all BLoC and Cubit logic.
*   Use the `blocTest` function.

```dart
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

void main() {
  group('UserCubit', () {
    late MockUserRepository mockRepo;

    setUp(() {
      mockRepo = MockUserRepository();
    });

    blocTest<UserCubit, UserState>(
      'emits [UserLoading, UserLoaded] on successful fetch',
      build: () {
        when(() => mockRepo.getUser('123'))
            .thenAnswer((_) async => Right(testUser));
        return UserCubit(mockRepo);
      },
      act: (cubit) => cubit.fetchUser('123'),
      expect: () => [
        const UserLoading(),
        const UserLoaded(testUser),
      ],
    );
  });
}
```

## Integration Testing
*   Place tests in the `integration_test/` directory.
*   Initialize the binding: `IntegrationTestWidgetsFlutterBinding.ensureInitialized();`
*   Do NOT use hardcoded text strings (like `find.text('Login')`) because the project is localized using `slang`. Tests will fail if the language changes.
*   Use `find.byKey(ValueKey('identifier'))` to find widgets.

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:shinga/main.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('App launch and button tap test', (tester) async {
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    final buttonFinder = find.byKey(const ValueKey('login_button'));
    expect(buttonFinder, findsOneWidget);

    await tester.tap(buttonFinder);
    await tester.pumpAndSettle();
  });
}
```

## Execution & Coverage

Run tests using Flutter CLI:
```bash
# Run all tests
flutter test

# Run tests and generate coverage
flutter test --coverage

# Run integration tests
flutter test integration_test
```