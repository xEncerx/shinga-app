import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart' show ThemeMode;
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/data.dart';
import '../../../i18n/strings.g.dart';

part 'settings_state.dart';

class SettingsCubit extends Cubit<SettingsState> {
  SettingsCubit(this._appSettings) : super(SettingsState(_appSettings));

  AppSettings get settings => state.settings;

  Future<void> setLanguage(AppLocale language) async {
    _appSettings.language = language;
    await LocaleSettings.setLocale(language);

    emit(SettingsState(_appSettings));
  }

  void setTheme(ThemeMode theme) {
    _appSettings.theme = theme;
    emit(SettingsState(_appSettings));
  }

  void setCardButtonStyle(bool isCardButtonStyle) {
    _appSettings.isCardButtonStyle = isCardButtonStyle;
    emit(SettingsState(_appSettings));
  }

  void setColorScheme(FlexScheme colorScheme) {
    _appSettings.colorScheme = colorScheme;
    emit(SettingsState(_appSettings));
  }

  void setWebViewUsage(bool useWebView) {
    _appSettings.useWebView = useWebView;
    emit(SettingsState(_appSettings));
  }

  final AppSettings _appSettings;
}
