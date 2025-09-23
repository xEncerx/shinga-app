import 'package:hive_ce_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';

import '../../../hive/hive_registrar.g.dart';
import '../models/models.dart';

/// Repository for managing local database operations using Hive.
class LocalDatabaseRepository {
  late final Box<AppSettings> _settingsBox;
  late final Box<SearchHistoryItem> _searchHistoryBox;

  /// Initializes the local database repository.
  Future<void> initialize() async {
    final defaultPath = await getApplicationDocumentsDirectory();
    final databasePath = '${defaultPath.path}/shinga/database';
    await Hive.initFlutter(databasePath);
    Hive.registerAdapters();

    _settingsBox = await Hive.openBox<AppSettings>('app_settings');
    _searchHistoryBox = await Hive.openBox<SearchHistoryItem>('search_history');
  }

  /// Gets the application settings.
  AppSettings get settings {
    if (_settingsBox.isEmpty) {
      final defaultSettings = AppSettings();
      _settingsBox.put('settings', defaultSettings);
      return defaultSettings;
    }
    return _settingsBox.get('settings')!;
  }

  Box<SearchHistoryItem> get searchHistoryBox => _searchHistoryBox;
}
