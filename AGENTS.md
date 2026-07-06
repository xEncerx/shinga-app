# AGENTS.md - Shinga Development Guide

## Project Overview

Shinga is a cross-platform manga tracker application built with a strict Feature-First Clean Architecture.

- **Framework:** Flutter (Dart)
- **State Management:** BLoC/Cubit (`flutter_bloc`)
- **Architecture:** Clean Architecture + Repository Pattern
- **Routing:** `auto_router`
- **Localization:** `slang`
- **Network:** `dio` + `retrofit`
- **DI:** Custom initialization steps + `InheritedWidget` (`lib/core/initialization`)
- **Error Handling:** `fpdart` (`Either`, `Option`) + custom `ExceptionMapper`
- **Codegen:** `build_runner`, `freezed`, `json_serializable`
- **Workspace:** Includes local packages `packages/ui_kit` and `packages/storage`.

## Development Commands

```bash
# Install dependencies
flutter pub get

# Add dependencies (Prefer CLI to ensure alphabetical sorting for the linter)
flutter pub add <name>
flutter pub add dev:<dev_name>

# Generate translations (required after modifying *.i18n.json)
dart run slang

# Run code generation (required after changing Freezed, Retrofit, or AutoRoute)
dart run build_runner build --delete-conflicting-outputs

# Code Quality
dart format .
flutter analyze
dart fix --apply
```

## AI Agent Skills Router

**CRITICAL INSTRUCTION FOR AI AGENTS:**
Do NOT guess how to implement features in this project. You MUST use the `skill` tool to load the relevant instructions before writing code. Look at the table below and invoke the matching skill for your task.

| Task / Goal                                  | Skill to Load                       | Description                                                                                                            |
| :------------------------------------------- | :---------------------------------- | :--------------------------------------------------------------------------------------------------------------------- |
| **Understand Architecture / Create Feature** | `flutter-clean-architecture`        | Explains the Feature-First layers, BLoC + fpdart (`Either`), Retrofit DTOs, and the strict rules for Repositories.     |
| **Build UI / Theming / Layout**              | `flutter-ui-theming`                | Rules for NO HARDCODING. Explains how to use `ui_kit` (AppSpacing, AppColors, AppRadius) and `responsive_framework`.   |
| **Write Tests**                              | `flutter-testing-guide`             | Explains the AAA pattern using `mocktail` (no codegen), `bloc_test`, and `flutter_test`.                               |
| **Add Translations / Handle Errors**         | `flutter-localization-errors`       | Explains `slang` usage and the strict 6-step pipeline to map Data exceptions to Domain failures and UI localized text. |
| **Resolve Pub Conflicts**                    | `flutter-resolve-package-conflicts` | Commands and workflows for fixing `pubspec.yaml` and lockfile issues in Flutter.                                       |

## Coding Standards (Critical)

### Imports

- **ALWAYS** use package imports, **NEVER** relative imports.
  - Correct: `import 'package:shinga/features/home/home.dart';`
  - Incorrect: `import '../home/home.dart';`
- **ALWAYS** sort imports alphabetically. Rely on `dart format .` and the `directives_ordering` linter rule.
- **NEVER** manually separate imports into groups with blank lines to avoid conflicts with the linter.

## Documentation Standards

Add `dartdoc`-style comments (`///`) to all public APIs — classes, constructors, methods, top-level functions.

### Formatting Rules

- Start with a single-sentence summary ending with a period.
- Add a blank line after the summary to separate it from details.
- Document **why**, not **what** — the code itself should be self-explanatory.
- Use backticks for code references (e.g. ``  final `User`  ``).
- Do NOT document both getter and setter — only one.
- Place doc comments before annotations.

```dart
/// A repository for fetching user data from the remote API.
///
/// Handles authentication token injection and response caching.
/// Returns [AppFailure] on network or server errors.
class UserRepositoryImpl implements UserRepository {
  ...
}
```

## Codegen Requirements

You MUST run the `build_runner` command after modifying:

- Classes annotated with `@freezed`
- Classes annotated with `@JsonSerializable()`
- API clients annotated with `@RestApi()`
- AutoRoute definitions (`@RoutePage()`)

You MUST run `dart run slang` after modifying:

- `lib/i18n/*.i18n.json` files.
