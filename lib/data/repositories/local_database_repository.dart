import 'package:hive_ce_flutter/hive_flutter.dart';

import '../../../hive/hive_registrar.g.dart';
import '../models/models.dart';

class LocalDatabaseRepository {
  late final Box<AppSettings> _settingsBox;
  late final Box<SearchHistoryItem> _searchHistoryBox;

  Future<void> initialize() async {
    await Hive.initFlutter();
    Hive.registerAdapters();

    _settingsBox = await Hive.openBox<AppSettings>('app_settings');
    _searchHistoryBox = await Hive.openBox<SearchHistoryItem>('search_history');
  }

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
