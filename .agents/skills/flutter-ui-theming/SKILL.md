---
name: flutter-ui-theming
description: Guidelines for building UI, using ui_kit, theming, and responsive layout. Use when writing widgets, screens, or designing components.
---
# Flutter UI, Theming & Layout

## Contents
- [Core UI Rules (Strict Restrictions)](#core-ui-rules-strict-restrictions)
- [Using `ui_kit`](#using-ui_kit)
- [Responsive Layout](#responsive-layout)
- [Examples](#examples)

## Core UI Rules (Strict Restrictions)

*   **NO HARDCODING COLORS:** Never use `Colors.red`, `Color(0xFF...)`, etc. 
    *   Use `context.appColors` for custom project colors.
    *   Use `context.colors` to access Material `ColorScheme`.
*   **NO HARDCODING SPACING:** Never use hardcoded numbers for paddings, margins, or SizedBox dimensions (e.g. `SizedBox(height: 16)` or `EdgeInsets.all(12)`).
    *   Use values from `AppSpacing` (e.g. `AppSpacing.md`).
*   **NO HARDCODING RADII:** Never use hardcoded numbers for border radiuses.
    *   Use values from `AppRadius` (e.g. `AppRadius.md`).
*   **NO HARDCODING TEXT STYLES:** Never manually define `TextStyle`.
    *   Use `AppTextStyle` (if defined in `ui_kit`).
*   **ALWAYS USE `const` CONSTRUCTORS:** Use `const` constructors for widgets and in `build()` methods whenever possible. This reduces rebuilds and improves performance.
    *   Correct: `const SizedBox(height: AppSpacing.sm)`, `const Text('Hello')`, `const Padding(padding: ...)`.
    *   Incorrect: `SizedBox(height: AppSpacing.sm)`, `Text('Hello')` (when no non-const fields).
*   **PRIVATE WIDGET CLASSES OVER HELPER METHODS:** Break down large `build()` methods into smaller, private `Widget` classes. Do NOT use private helper methods that return a `Widget` — they hurt performance (no const, no keys) and violate composition principles.
    *   Correct: Define a separate `_HeaderSection extends StatelessWidget`.
    *   Incorrect: `Widget _buildHeader() => ...` inside the parent widget.

## Using `ui_kit`

The project contains a workspace package `packages/ui_kit`. It houses reusable UI components, tokens (colors, spacing, radius), and extensions.

*   Always `import 'package:ui_kit/ui_kit.dart';` when building UI.
*   Before using standard Flutter widgets (e.g., `ElevatedButton`, `TextField`, `Card`), check if a corresponding custom widget exists in `ui_kit` (e.g., `SaPrimaryButton`, `SaTextField`). If a custom `ui_kit` component exists, you MUST use it.
*   General-purpose widgets go into `packages/ui_kit/lib/src/widgets/`.
*   Feature-specific widgets stay in `lib/features/<feature>/presentation/widgets/`.

## Responsive Layout

*   The project uses `responsive_framework` for adapting layouts to different screen sizes.
*   Do NOT use standard `LayoutBuilder` with hardcoded breakpoints or `MediaQuery` manual size checks for changing layouts.
*   Use `ResponsiveBreakpoints.of(context)` or `ResponsiveValue` from the `responsive_framework` package to determine the current screen size and conditionally render different widget trees (e.g., list vs grid, bottom nav vs side rail).

## Examples

### Building a Standard Card

```dart
import 'package:flutter/material.dart';
import 'package:ui_kit/ui_kit.dart'; // REQUIRED

class CustomUserCard extends StatelessWidget {
  const CustomUserCard({super.key, required this.userName});
  final String userName;

  @override
  Widget build(BuildContext context) {
    return Container(
      // Correct padding using AppSpacing
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        // Correct color using context extension
        color: context.colors.primary, 
        // Correct radius using AppRadius
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Column(
        children: [
          SaText(
            userName,
            // Use predefined text styles
            style: AppTextStyle.title,
          ),
          // Correct spacing
          const SizedBox(height: AppSpacing.sm),
          // Assuming SaPrimaryButton is provided by ui_kit
          SaPrimaryButton(
            onPressed: () {},
            child: SaText('View Profile'),
          ),
        ],
      ),
    );
  }
}
```

### Private Widget Classes (Not Helper Methods)

```dart
// DON'T: private helper method returning Widget
class UserProfileScreen extends StatelessWidget {
  ...
  @override
  Widget build(BuildContext context) {
    return Column(children: [_buildHeader(), _buildBody(), _buildFooter()]);
  }

  Widget _buildHeader() => ...;  // ❌ No const, no key, composition issues
  Widget _buildBody() => ...;    // ❌
}

// DO: separate private Widget classes
class UserProfileScreen extends StatelessWidget {
  const UserProfileScreen({super.key, ...});
  ...
  @override
  Widget build(BuildContext context) {
    return const Column(children: [
      _HeaderSection(),
      _BodySection(),
      _FooterSection(),
    ]);
  }
}

class _HeaderSection extends StatelessWidget {
  const _HeaderSection();
  @override
  Widget build(BuildContext context) { ... }
}

class _BodySection extends StatelessWidget {
  const _BodySection();
  @override
  Widget build(BuildContext context) { ... }
}
```

### Responsive Design with responsive_framework

```dart
import 'package:flutter/material.dart';
import 'package:responsive_framework/responsive_framework.dart';

class ResponsiveList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Checking breakpoint directly
    final isWide = ResponsiveBreakpoints.of(context).largerThan(TABLET);

    return isWide 
      ? _buildGrid() 
      : _buildList();
  }
}
```