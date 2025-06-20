import 'package:hive_ce/hive.dart';

import '../../core/core.dart';

class AppSettings extends HiveObject {
  /// Represents the application settings.
  /// Default values:
  /// - `isDarkTheme`: true
  /// - `isCardButtonStyle`: false
  /// - `languageCode`: "ru"
  /// - `useWebView`: true
  /// - `suggestProvider`: MangaSource.mangaPoisk
  AppSettings({
    this.isDarkTheme = true,
    this.isCardButtonStyle = false,
    this.languageCode = "ru",
    this.useWebView = true,
    this.suggestProvider = MangaSource.mangaPoisk,
  });

  bool isDarkTheme;
  bool isCardButtonStyle;
  String languageCode;
  bool useWebView;
  MangaSource suggestProvider;
}
