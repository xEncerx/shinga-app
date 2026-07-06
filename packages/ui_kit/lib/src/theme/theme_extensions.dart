import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';
import 'package:ui_kit/src/src.dart';

/// Extension on [BuildContext] to provide easy access to theme properties.
extension ThemeExtras on BuildContext {
  /// Gets the current [ColorScheme] from the theme.
  ColorScheme get colors => Theme.of(this).colorScheme;

  /// Gets the custom [AppColors] from the theme extensions.
  AppColors get appColors => Theme.of(this).extension<AppColors>()!;

  /// Gets the custom [LoggerColors] from the theme extensions.
  LoggerColors get loggerColors => Theme.of(this).extension<LoggerColors>()!;

  /// Gets the current [TextTheme] from the theme.
  TextTheme get textTheme => Theme.of(this).textTheme;
}

/// Extension on [ThemeData] to provide a method for getting the effective primary color based on the color scheme.
extension PrimaryThemeColor on ThemeData {
  /// Returns the effective primary color based on the current brightness and provided [FlexScheme].
  Color effectivePrimaryColor(FlexScheme colorScheme) {
    if (brightness == Brightness.dark) {
      return FlexThemeData.dark(scheme: colorScheme).colorScheme.primary;
    } else {
      return FlexThemeData.light(scheme: colorScheme).colorScheme.primary;
    }
  }
}
