import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:shinga/domain/domain.dart';

part 'app_settings.freezed.dart';

/// Application settings containing user preferences.
@freezed
abstract class AppSettings with _$AppSettings {
  /// Creates an [AppSettings] instance.
  const factory AppSettings({
    /// The preferred reading mode for titles.
    required TitleReadMode readMode,

    /// The display style for title items.
    required TitleButtonStyle titleButtonStyle,

    /// The application theme mode.
    required AppThemeMode themeMode,

    /// The application color scheme.
    required AppColorScheme colorScheme,

    /// The application language.
    required AppLanguage language,

    required bool isAdBlockerEnabled,

    required List<AdBlockerFilterSubscription> adBlockerFilterSubscriptions,
  }) = _AppSettings;

  /// Default application settings.
  static const defaults = AppSettings(
    readMode: TitleReadMode.webView,
    titleButtonStyle: TitleButtonStyle.card,
    themeMode: AppThemeMode.system,
    colorScheme: AppColorScheme.shadBlue,
    language: AppLanguage.system,
    isAdBlockerEnabled: false,
    adBlockerFilterSubscriptions: [],
  );
}
