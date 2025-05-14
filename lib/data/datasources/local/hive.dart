import 'package:hive_ce_flutter/hive_flutter.dart';

import '../../../hive/hive_registrar.g.dart';
import '../../models/models.dart';

class HiveDatasource {
  factory HiveDatasource() => _instance;
  HiveDatasource._internal();
  static final HiveDatasource _instance = HiveDatasource._internal();

  late final Box<AppSettings> settingsBox;
  late final Box<SearchHistoryItem> searchHistoryBox;

  Future<void> initialize() async {
    await Hive.initFlutter();
    Hive.registerAdapters();

    settingsBox = await Hive.openBox<AppSettings>("settings");
    searchHistoryBox = await Hive.openBox<SearchHistoryItem>("search_history");

    await _initializeDefaultSettings();
  }

  Future<void> _initializeDefaultSettings() async {
    if (settingsBox.isEmpty) {
      final defaultSettings = AppSettings();

      await settingsBox.add(defaultSettings);
    }
  }

  Future<void> close() async {
    await Hive.close();
  }
}
