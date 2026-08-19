import 'package:shinga/core/types/types.dart';
import 'package:shinga/domain/domain.dart';

/// A repository that handles application settings operations.
abstract class AppSettingsRepository {
  /// Retrieves the current application settings.
  Future<Either<AppFailure, AppSettings>> getSettings();

  /// Saves the given application settings.
  Future<Either<AppFailure, void>> saveSettings(AppSettings settings);

  /// Updates the settings using the provided update function.
  Future<Either<AppFailure, void>> updateSettings(
    AppSettings Function(AppSettings current) update,
  );

  /// Watches the application settings for changes.
  Stream<AppSettings> watchSettings();
}
