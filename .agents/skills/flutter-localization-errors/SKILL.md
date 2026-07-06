---
name: flutter-localization-errors
description: Guidelines for managing localization (slang) and the pipeline for handling domain errors. Use when adding text to the UI or mapping new API/System exceptions to UI error messages.
---
# Localization & Error Handling Pipeline

## Contents
- [Localization (slang)](#localization-slang)
- [Error Handling Pipeline](#error-handling-pipeline)

## Localization (slang)

The project uses the `slang` package for localization. Translation files are located in `lib/i18n/`.

*   **UI (Presentation Layer):**
    *   ALWAYS use `Translations.of(context)` or `final t = Translations.of(context)` inside the `build` method. This ensures the UI rebuilds when the locale changes.
    *   NEVER use hardcoded strings for UI text.
*   **Business Logic (Domain/Data/Outside Build context):**
    *   Use the global `t` variable (imported from `lib/i18n/strings.g.dart`) for exceptions, enums, or extensions where `BuildContext` is unavailable.
*   **Nesting:** Group translations logically. E.g., `t.auth.loginButton` instead of flat names.
*   **Codegen:** After editing `*.i18n.json` files, run:
    ```bash
    dart run slang
    ```

## Error Handling Pipeline

When integrating a new API call that returns a specific error or handling a new system exception, follow this strict pipeline to map it from the Data layer to localized UI strings.

**Task Progress:**
- [ ] **Step 1: Domain Class.** Create a domain error class inheriting from `AppFailure` in `lib/domain/failures/`. You MUST provide a unique `code`.
    ```dart
    // lib/domain/failures/my_feature_failure.dart
    final class CustomApiFailure extends AppFailure {
      const CustomApiFailure({super.details}) : super(code: 'CustomApiError');
    }
    ```
- [ ] **Step 2: ExceptionMapper.** Add the mapping logic in `lib/data/exception_mapper.dart`. If it's a specific HTTP status or a string error code returned in the API DTO, add a case to the relevant switch statement (e.g. `_fromErrorCode` or `_fromStatusCode`) to return your new domain failure.
    ```dart
    static AppFailure _fromErrorCode(String errorCode, ...) {
      return switch(errorCode) {
        'CustomApiError' => CustomApiFailure(details: details),
        // ...
      };
    }
    ```
- [ ] **Step 3: JSON Localization.** Add the translation keys to both `lib/i18n/en.i18n.json` and `ru.i18n.json` under the `failures` node. Include a `title` (short) and `description` (user-friendly).
    ```json
    "failures": {
      "customApiError": {
        "title": "Custom Error",
        "description": "Something went wrong specifically here."
      }
    }
    ```
- [ ] **Step 4: Extension Mapping.** Open `lib/i18n/extensions/app_failure_i18n.dart`. Add a case to the switch statement mapping your failure `code` to a `FailureMessage` using the global `t` variable.
    ```dart
    extension AppFailureI18n on AppFailure {
      FailureMessage toMessage() {
        final failures = t.failures;
        return switch (code) {
          'CustomApiError' => FailureMessage(
            title: failures.customApiError.title,
            description: failures.customApiError.description,
          ),
          // ...
        };
      }
    }
    ```
- [ ] **Step 5: Run slang.** Run `dart run slang` to generate the getters.
- [ ] **Step 6: UI Usage.** In the Presentation layer, call `.toMessage()` on the failure to display it.
    ```dart
    final message = failure.toMessage();
    showDialog(title: message.title, body: message.description);
    ```