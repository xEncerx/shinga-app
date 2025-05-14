part of 'app_settings_cubit.dart';

final class AppSettingsState{
  AppSettingsState({AppSettings? appSettings}) : appSettings = appSettings ?? AppSettings();

  final AppSettings appSettings;
}
