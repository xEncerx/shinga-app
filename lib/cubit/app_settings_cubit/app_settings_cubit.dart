import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';

import '../../data/data.dart';
import '../../domain/domain.dart';
import '../../i18n/strings.g.dart';

part 'app_settings_state.dart';

class AppSettingsCubit extends Cubit<AppSettingsState> {
  AppSettingsCubit() : super(AppSettingsState()) {
    getSettings();
  }

  Future<void> setCardButtonStyle(bool isCardButtonStyle) async {
    await settings.setCardButtonStyle(isCard: isCardButtonStyle);
    getSettings();
  }

  Future<void> setLanguageCode(String languageCode) async {
    if (!AppLocaleUtils.supportedLocales.any((locale) => locale.languageCode == languageCode)) {
      languageCode = 'en';
    }

    LocaleSettings.setLocaleRaw(languageCode);
    await settings.setLanguageCode(languageCode: languageCode);

    getSettings();
  }

  Future<void> setDarkTheme(bool isDarkTheme) async {
    await settings.setDarkTheme(isDark: isDarkTheme);
    getSettings();
  }

  Future<void> setSuggestProvider(MangaSource suggestProvider) async {
    await settings.setSuggestProvider(suggestProvider: suggestProvider);
    getSettings();
  }

  void getSettings() {
    final appSettings = settings.getAppSettings();
    emit(
      AppSettingsState(appSettings: appSettings),
    );
  }

  final settings = GetIt.I<SettingsRepository>();
}
