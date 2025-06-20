import '../../../data/data.dart';
import '../../core/core.dart';

class SettingsRepository {
  SettingsRepository(this._hiveDatasource);

  final HiveDatasource _hiveDatasource;

  /// Returns the app settings, creating a new instance if it doesn't exist
  AppSettings getAppSettings() {
    final appSettings = _hiveDatasource.settingsBox.getAt(0);
    return appSettings ?? AppSettings();
  }

  /// Updates the app settings using the provided update function
  Future<void> updateSettings(
    void Function(AppSettings appSettings) updateFunction,
  ) async {
    final appSettings = getAppSettings();
    updateFunction(appSettings);
    await _hiveDatasource.settingsBox.putAt(0, appSettings);
  }

  /// Updates the dark theme mode in app settings
  Future<void> setDarkTheme({required bool isDark}) async {
    await updateSettings((settings) {
      settings.isDarkTheme = isDark;
    });
  }

  /// Updates the manga source in app settings
  Future<void> setSuggestProvider({required MangaSource suggestProvider}) async {
    await updateSettings((settings) {
      settings.suggestProvider = suggestProvider;
    });
  }

  /// Updates the card button style in app settings
  Future<void> setCardButtonStyle({required bool isCard}) async {
    await updateSettings((settings) {
      settings.isCardButtonStyle = isCard;
    });
  }

  /// Updates the WebView status in app settings
  Future<void> setWebViewStatus({required bool useWebView}) async {
    await updateSettings((settings) {
      settings.useWebView = useWebView;
    });
  }

  /// Updates the language code in app settings
  Future<void> setLanguageCode({required String languageCode}) async {
    await updateSettings((settings) {
      settings.languageCode = languageCode;
    });
  }

  /// Returns current language code from app settings
  String getLanguageCode() {
    return getAppSettings().languageCode;
  }
}
