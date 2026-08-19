import 'package:shinga/core/core.dart';
import 'package:shinga/data/data.dart';
import 'package:shinga/domain/domain.dart';
import 'package:shinga/features/features.dart';

/// Implements [AppSettingsRepository] with a transactional Drift DAO.
class AppSettingsRepositoryImpl implements AppSettingsRepository {
  /// Creates an [AppSettingsRepositoryImpl] instance.
  const AppSettingsRepositoryImpl(this._dao);

  final AppSettingsDao _dao;

  @override
  Future<Either<AppFailure, AppSettings>> getSettings() {
    return ExceptionMapper.guard(() async {
      final stored = await StorageExceptionGuard.read(_dao.getSettings);
      return stored?.toDomain() ?? AppSettings.defaults;
    });
  }

  @override
  Future<Either<AppFailure, void>> saveSettings(AppSettings settings) {
    return ExceptionMapper.guardVoid(() async {
      await _saveSettings(settings);
    });
  }

  @override
  Future<Either<AppFailure, void>> updateSettings(
    AppSettings Function(AppSettings current) update,
  ) {
    return ExceptionMapper.guardVoid(() async {
      await StorageExceptionGuard.write(
        () => _dao.updateSettings(
          (stored) => _toStoredSettings(
            update(stored?.toDomain() ?? AppSettings.defaults),
          ),
        ),
      );
    });
  }

  @override
  Stream<AppSettings> watchSettings() =>
      _dao.watchSettings().map((stored) => stored?.toDomain() ?? AppSettings.defaults).distinct();

  Future<void> _saveSettings(AppSettings settings) {
    final stored = _toStoredSettings(settings);
    return StorageExceptionGuard.write(
      () => _dao.saveSettings(
        settings: stored.settings.toCompanion(true),
        filterSubscriptionUrls: stored.filterSubscriptionUrls,
      ),
    );
  }

  StoredAppSettings _toStoredSettings(AppSettings settings) => StoredAppSettings(
    settings: AppSettingsRow(
      id: 1,
      readMode: settings.readMode.name,
      titleButtonStyle: settings.titleButtonStyle.name,
      themeMode: settings.themeMode.name,
      colorScheme: settings.colorScheme.name,
      language: settings.language.name,
      isAdBlockerEnabled: settings.isAdBlockerEnabled,
    ),
    filterSubscriptionUrls: settings.adBlockerFilterSubscriptions
        .map((subscription) => subscription.url)
        .toList(),
  );
}

extension on StoredAppSettings {
  AppSettings toDomain() => AppSettings(
    readMode: TitleReadMode.values.byNameOrDefault(
      settings.readMode,
      AppSettings.defaults.readMode,
    ),
    titleButtonStyle: TitleButtonStyle.values.byNameOrDefault(
      settings.titleButtonStyle,
      AppSettings.defaults.titleButtonStyle,
    ),
    themeMode: AppThemeMode.values.byNameOrDefault(
      settings.themeMode,
      AppSettings.defaults.themeMode,
    ),
    colorScheme: AppColorScheme.values.byNameOrDefault(
      settings.colorScheme,
      AppSettings.defaults.colorScheme,
    ),
    language: AppLanguage.values.byNameOrDefault(
      settings.language,
      AppSettings.defaults.language,
    ),
    isAdBlockerEnabled: settings.isAdBlockerEnabled,
    adBlockerFilterSubscriptions: filterSubscriptionUrls
        .map((url) => AdBlockerFilterSubscription(url: url))
        .toList(),
  );
}
