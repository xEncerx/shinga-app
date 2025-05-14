import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class AppTheme {
  static const Color primaryBlue = Color(0xFF0099FF);
  static const Color darkBackground = Color(0xFF181C25);
  static const Color darkCardBackground = Color(0xFF303642);
  // static const Color darkAppBarBackground = Color(0xFF22262F);
  static const Color readingHighLight = Color(0xFFC252FF);
  static const Color completedHighLight = Color(0xFFFAC022);
  static const Color onFutureHighLight = Color(0xFF3B9CF1);
  static const Color notReadingHighLight = Color(0xFFD42025);

  static ThemeData darkTheme() {
    return FlexThemeData.dark(
      scheme: FlexScheme.shadBlue,
      scaffoldBackground: darkBackground,
      dialogBackground: darkBackground,
      subThemesData: const FlexSubThemesData(
        interactionEffects: true,
        tintedDisabledControls: true,
        blendOnColors: true,
        useM2StyleDividerInM3: true,
        inputDecoratorIsFilled: true,
        inputDecoratorBorderType: FlexInputBorderType.outline,
        inputDecoratorUnfocusedHasBorder: false,
        alignedDropdown: true,
        navigationRailUseIndicator: true,
      ),
      cupertinoOverrideTheme: const CupertinoThemeData(
        applyThemeToAll: true,
      ),
      visualDensity: FlexColorScheme.comfortablePlatformDensity,
      fontFamily: "Nunito",
    ).copyWith(
      hintColor: const Color(0xFFA0A0A0),
      cardColor: darkCardBackground,
      appBarTheme: const AppBarTheme(
        backgroundColor: darkBackground,
        scrolledUnderElevation: 0,
        elevation: 0,
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        dismissDirection: DismissDirection.horizontal,
        contentTextStyle: const TextStyle(
          fontSize: 14,
          color: Colors.black,
        ),
      ),
      tabBarTheme: TabBarTheme(
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: Colors.transparent,
        indicator: UnderlineTabIndicator(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: primaryBlue, width: 3),
        ),
        tabAlignment: TabAlignment.center,
        labelStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
