import 'package:hive_ce/hive.dart';

class AppSettings extends HiveObject {
  AppSettings({
    this.isDarkTheme = true,
    this.isCardButtonStyle = false,
    this.languageCode = "ru",
  });

  bool isDarkTheme;
  bool isCardButtonStyle;
  String languageCode;
}
