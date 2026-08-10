import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shinga/domain/domain.dart';
import 'package:shinga/features/features.dart';

part 'app_settings_state.dart';

/// A cubit that manages application settings state.
class AppSettingsCubit extends Cubit<AppSettingsState> {
  /// Creates an [AppSettingsCubit] instance.
  AppSettingsCubit(this._appSettingsRepository) : super(const AppSettingsState()) {
    _settingsSubscription = _appSettingsRepository.watchSettings().listen(
      (settings) => emit(
        state.copyWith(
          settings: settings,
          isLoading: false,
          clearFailure: true,
        ),
      ),
    );
  }

  /// The repository used to access application settings.
  final AppSettingsRepository _appSettingsRepository;
  late final StreamSubscription<AppSettings> _settingsSubscription;

  /// Changes the reading mode setting.
  Future<void> changeReadMode(TitleReadMode readMode) => _updateSettings(
    state.settings.copyWith(readMode: readMode),
  );

  /// Changes the title button style setting.
  Future<void> changeTitleButtonStyle(TitleButtonStyle titleButtonStyle) => _updateSettings(
    state.settings.copyWith(titleButtonStyle: titleButtonStyle),
  );

  /// Changes the theme mode setting.
  Future<void> changeThemeMode(AppThemeMode themeMode) => _updateSettings(
    state.settings.copyWith(themeMode: themeMode),
  );

  /// Changes the color scheme setting.
  Future<void> changeColorScheme(AppColorScheme colorScheme) => _updateSettings(
    state.settings.copyWith(colorScheme: colorScheme),
  );

  /// Changes the language setting.
  Future<void> changeLanguage(AppLanguage language) => _updateSettings(
    state.settings.copyWith(language: language),
  );

  /// Changes the ad blocker status setting.
  Future<void> changeAdBlockerStatus(bool isEnabled) => _updateSettings(
    state.settings.copyWith(isAdBlockerEnabled: isEnabled),
  );

  /// Changes the ad blocker filter subscriptions setting.
  Future<void> changeAdBlockerFilterSubscriptions(
    List<AdBlockerFilterSubscription> subscriptions,
  ) => _updateSettings(state.settings.copyWith(adBlockerFilterSubscriptions: subscriptions));

  Future<void> _updateSettings(AppSettings updated) async {
    if (updated == state.settings) return;
    emit(state.copyWith(isLoading: true));

    final result = await _appSettingsRepository.saveSettings(updated);
    result.fold(
      (failure) => emit(state.copyWith(isLoading: false, failure: failure)),
      (_) => emit(
        state.copyWith(
          settings: updated,
          isLoading: false,
          clearFailure: true,
        ),
      ),
    );
  }

  @override
  Future<void> close() async {
    await _settingsSubscription.cancel();
    return super.close();
  }
}
