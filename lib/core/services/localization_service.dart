// core/services/localization_service.dart
import 'dart:async';

import 'package:shinga/domain/domain.dart';
import 'package:shinga/features/features.dart';
import 'package:shinga/i18n/i18n.dart';
import 'package:shinga/i18n/strings.g.dart';

/// A service that manages application localization based on user settings.
class LocalizationService {
  /// Creates a [LocalizationService] instance.
  LocalizationService(this._settingsRepository);

  /// The repository used to access application settings.
  final AppSettingsRepository _settingsRepository;
  StreamSubscription<AppSettings>? _subscription;

  /// Initializes the localization service and subscribes to settings changes.
  Future<void> initialize() async {
    final result = await _settingsRepository.getSettings();
    await result.fold(
      (_) => null,
      (settings) => _updateLocale(settings.language),
    );

    _subscription = _settingsRepository.watchSettings().listen((settings) async {
      final currentLanguage = t.language;
      if (currentLanguage == settings.language) return;

      await _updateLocale(settings.language);
    });
  }

  Future<void> _updateLocale(AppLanguage language) async {
    switch (language) {
      case AppLanguage.ru:
        await LocaleSettings.setLocale(AppLocale.ru);
      case AppLanguage.en:
        await LocaleSettings.setLocale(AppLocale.en);
      case AppLanguage.system:
        await LocaleSettings.useDeviceLocale();
    }
  }

  /// Disposes the subscription to settings changes.
  void dispose() => _subscription?.cancel();
}
