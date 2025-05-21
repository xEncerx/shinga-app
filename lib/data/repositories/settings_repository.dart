import '../../../data/data.dart';
import '../../core/core.dart';

class SettingsRepository {
  SettingsRepository(this._hiveDatasource);

  final HiveDatasource _hiveDatasource;

  AppSettings getAppSettings() {
    final allSettings = _hiveDatasource.settingsBox.getAt(0);
    return allSettings ?? AppSettings();
  }

  Future<void> setDarkTheme({required bool isDark}) async {
    final allSettings = getAppSettings();
    allSettings.isDarkTheme = isDark;

    await _hiveDatasource.settingsBox.putAt(0, allSettings);
  }

  Future<void> setSuggestProvider({required MangaSource suggestProvider}) async {
    final allSettings = getAppSettings();
    allSettings.suggestProvider = suggestProvider;

    await _hiveDatasource.settingsBox.putAt(0, allSettings);
  }

  Future<void> setCardButtonStyle({required bool isCard}) async {
    final allSettings = getAppSettings();
    allSettings.isCardButtonStyle = isCard;

    await _hiveDatasource.settingsBox.putAt(0, allSettings);
  }

  String getLanguageCode() {
    return getAppSettings().languageCode;
  }

  Future<void> setLanguageCode({required String languageCode}) async {
    final allSettings = getAppSettings();
    allSettings.languageCode = languageCode;

    await _hiveDatasource.settingsBox.putAt(0, allSettings);
  }
}
