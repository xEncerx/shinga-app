import 'package:hive_ce_flutter/hive_flutter.dart';

import '../../../hive/hive_registrar.g.dart';
import '../../models/models.dart';

class HiveDatasource {
  factory HiveDatasource() => _instance;
  HiveDatasource._internal();
  static final HiveDatasource _instance = HiveDatasource._internal();

  late final Box<AppSettings> settingsBox;
  late final Box<SearchHistoryItem> searchHistoryBox;

  /// Initializes Hive and opens the necessary boxes.
  Future<void> initialize() async {
    await Hive.initFlutter();
    Hive.registerAdapters();

    settingsBox = await Hive.openBox<AppSettings>("settings");
    searchHistoryBox = await Hive.openBox<SearchHistoryItem>("search_history");

    await _initializeDefaultSettings();
  }

  /// Initializes default settings if the settings box is empty.
  Future<void> _initializeDefaultSettings() async {
    if (settingsBox.isEmpty) {
      final defaultSettings = AppSettings();

      await settingsBox.add(defaultSettings);
    }
  }

  /// Closes all Hive boxes.
  Future<void> close() async {
    await Hive.close();
  }
}
