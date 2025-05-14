import 'package:hive_ce/hive.dart';

class AppSettings extends HiveObject {
  AppSettings({
    this.isDarkTheme = false,
    this.isCardButtonStyle = true,
    this.languageCode = "en",
  });

  bool isDarkTheme;
  bool isCardButtonStyle;
  String languageCode;
}
