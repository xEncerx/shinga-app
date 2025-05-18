import 'package:hive_ce/hive.dart';

import '../../domain/domain.dart';

class AppSettings extends HiveObject {
  AppSettings({
    this.isDarkTheme = true,
    this.isCardButtonStyle = false,
    this.languageCode = "ru",
    this.suggestProvider = MangaSource.mangaPoisk,
  });

  bool isDarkTheme;
  bool isCardButtonStyle;
  String languageCode;
  MangaSource suggestProvider;
}
