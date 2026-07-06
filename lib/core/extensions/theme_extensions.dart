import 'package:flutter/material.dart';
import 'package:shinga/domain/domain.dart';
import 'package:ui_kit/ui_kit.dart';

/// Extension to convert [AppThemeMode] to Flutter's [ThemeMode].
extension ThemeModeExtension on AppThemeMode {
  /// Converts [AppThemeMode] to [ThemeMode].
  ThemeMode toThemeMode() {
    return switch (this) {
      AppThemeMode.light => ThemeMode.light,
      AppThemeMode.dark => ThemeMode.dark,
      AppThemeMode.system => ThemeMode.system,
    };
  }
}

/// Extension to convert [AppColorScheme] to a [FlexScheme] for theming.
extension ColorSchemeExtension on AppColorScheme {
  /// Converts [AppColorScheme] to a [FlexScheme].
  FlexScheme toColorScheme() {
    return switch (this) {
      AppColorScheme.shadBlue => FlexScheme.shadBlue,
      AppColorScheme.shadGreen => FlexScheme.shadGreen,
      AppColorScheme.shadNeutral => FlexScheme.shadNeutral,
      AppColorScheme.shadOrange => FlexScheme.shadOrange,
      AppColorScheme.shadRed => FlexScheme.shadRed,
      AppColorScheme.shadRose => FlexScheme.shadRose,
      AppColorScheme.shadViolet => FlexScheme.shadViolet,
      AppColorScheme.shadYellow => FlexScheme.shadYellow,
    };
  }
}
