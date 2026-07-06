import 'package:fpdart/fpdart.dart';
import 'package:shinga/data/data.dart';
import 'package:shinga/domain/entities/app_settings.dart';
import 'package:shinga/domain/failures/app_failure.dart';
import 'package:shinga/features/features.dart';
import 'package:storage/storage.dart';

/// Implementation of [AppSettingsRepository] using local storage.
class AppSettingsRepositoryImpl implements AppSettingsRepository {
  /// Creates an [AppSettingsRepositoryImpl] instance.
  const AppSettingsRepositoryImpl(this._storage);

  /// The storage used for persisting settings.
  final CollectionStorage<AppSettingsDTO> _storage;

  static const String _kSettingsKey = 'app_settings';

  @override
  Future<Either<AppFailure, AppSettings>> getSettings() async {
    return ExceptionMapper.guard(() async {
      final dto = await _storage.read(_kSettingsKey);
      return dto?.toDomain() ?? AppSettings.defaults;
    });
  }

  @override
  Future<Either<AppFailure, Unit>> saveSettings(AppSettings settings) async {
    return ExceptionMapper.guard(() async {
      await _storage.write(_kSettingsKey, AppSettingsDTO.fromDomain(settings));
      return unit;
    });
  }

  @override
  Future<Either<AppFailure, Unit>> updateSettings(
    AppSettings Function(AppSettings current) update,
  ) {
    return ExceptionMapper.guard(() async {
      final dto = await _storage.read(_kSettingsKey);
      final current = dto?.toDomain() ?? AppSettings.defaults;

      final updated = update(current);
      await _storage.write(_kSettingsKey, AppSettingsDTO.fromDomain(updated));
      return unit;
    });
  }

  @override
  Stream<AppSettings> watchSettings() {
    return _storage.watch().map(
      (items) => items.firstOrNull?.toDomain() ?? AppSettings.defaults,
    );
  }
}
