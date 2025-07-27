import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';
import 'package:hive_ce/hive.dart';

import '../../i18n/strings.g.dart';

/// Represents application settings.
class AppSettings extends HiveObject {
  /// Initializes a new instance of [AppSettings] with default values.
  ///
  /// - `theme` - The theme of the application, defaulting to [ThemeMode.system].
  /// - `language` - The language of the application, defaulting to [AppLocale.en].
  /// - `isCardButtonStyle` - Whether the card title button style is enabled, defaulting to `true`.
  /// - `colorScheme` - The color scheme of the application, defaulting to [FlexScheme.shadBlue].
  AppSettings({
    ThemeMode theme = ThemeMode.system,
    AppLocale language = AppLocale.en,
    bool isCardButtonStyle = true,
    FlexScheme colorScheme = FlexScheme.shadBlue,
  }) : _theme = theme,
       _language = language,
       _isCardButtonStyle = isCardButtonStyle,
       _colorScheme = colorScheme;

  // AppSettings parameters
  ThemeMode _theme;
  AppLocale _language;
  bool _isCardButtonStyle;
  FlexScheme _colorScheme;

  // Theme getter and setter
  ThemeMode get theme => _theme;
  set theme(ThemeMode value) {
    _theme = value;
    save();
  }

  // Language getter and setter
  AppLocale get language => _language;
  set language(AppLocale value) {
    _language = value;
    save();
  }

  // Title button style getter and setter
  bool get isCardButtonStyle => _isCardButtonStyle;
  set isCardButtonStyle(bool value) {
    _isCardButtonStyle = value;
    save();
  }

  // Color scheme getter and setter
  FlexScheme get colorScheme => _colorScheme;
  set colorScheme(FlexScheme value) {
    _colorScheme = value;
    save();
  }
}
