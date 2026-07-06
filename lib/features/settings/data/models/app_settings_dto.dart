import 'package:shinga/core/core.dart';
import 'package:shinga/domain/domain.dart';

/// Data transfer object for application settings.
class AppSettingsDTO {
  /// Creates an [AppSettingsDTO] instance.
  const AppSettingsDTO({
    required this.readMode,
    required this.titleButtonStyle,
    required this.themeMode,
    required this.colorScheme,
    required this.language,
    required this.isAdBlockerEnabled,
    required this.adBlockerFilterSubscriptions,
  });

  /// Creates an [AppSettingsDTO] from a domain [AppSettings] object.
  factory AppSettingsDTO.fromDomain(AppSettings settings) {
    return AppSettingsDTO(
      readMode: settings.readMode.name,
      titleButtonStyle: settings.titleButtonStyle.name,
      themeMode: settings.themeMode.name,
      colorScheme: settings.colorScheme.name,
      language: settings.language.name,
      isAdBlockerEnabled: settings.isAdBlockerEnabled,
      adBlockerFilterSubscriptions: settings.adBlockerFilterSubscriptions
          .map((sub) => sub.toMap())
          .toList(),
    );
  }

  /// The reading mode as a string.
  final String readMode;

  /// The title button style as a string.
  final String titleButtonStyle;

  /// The theme mode as a string.
  final String themeMode;

  /// The color scheme as a string.
  final String colorScheme;

  /// The language as a string.
  final String language;

  /// Whether the ad blocker is enabled.
  final bool isAdBlockerEnabled;

  /// The list of ad blocker filter subscriptions represented as maps.
  final List<Map<String, String>> adBlockerFilterSubscriptions;

  /// Converts this DTO to a domain [AppSettings] object.
  AppSettings toDomain() {
    return AppSettings(
      readMode: TitleReadMode.values.byNameOrDefault(
        readMode,
        AppSettings.defaults.readMode,
      ),
      titleButtonStyle: TitleButtonStyle.values.byNameOrDefault(
        titleButtonStyle,
        AppSettings.defaults.titleButtonStyle,
      ),
      themeMode: AppThemeMode.values.byNameOrDefault(
        themeMode,
        AppSettings.defaults.themeMode,
      ),
      colorScheme: AppColorScheme.values.byNameOrDefault(
        colorScheme,
        AppSettings.defaults.colorScheme,
      ),
      language: AppLanguage.values.byNameOrDefault(
        language,
        AppSettings.defaults.language,
      ),
      isAdBlockerEnabled: isAdBlockerEnabled,
      adBlockerFilterSubscriptions: adBlockerFilterSubscriptions
          .map(AdBlockerFilterSubscription.fromMap)
          .toList(),
    );
  }
}
