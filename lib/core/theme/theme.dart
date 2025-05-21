import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class AppTheme {
  static const FlexScheme scheme = FlexScheme.shadBlue;
  static const Color darkBackground = Color(0xFF181C25);
  static const Color darkCardBackground = Color(0xFF303642);
  static const Color lightCardBackground = Color(0xFFEDF0F6);
  static const Color readingHighLight = Color(0xFFC252FF);
  static const Color completedHighLight = Color(0xFFF88D07);
  static const Color onFutureHighLight = Color(0xFF3B9CF1);
  static const Color notReadingHighLight = Color(0xFFD42025);

  static ThemeData darkTheme() {
    return FlexThemeData.dark(
      scheme: scheme,
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
      cardColor: darkCardBackground,
      appBarTheme: const AppBarTheme(
        shadowColor: darkCardBackground,
        backgroundColor: darkBackground,
        scrolledUnderElevation: 0,
        elevation: 0,
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: Colors.white,
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
          borderSide: BorderSide(
            color: scheme.data.dark.primary,
            width: 3,
          ),
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

  // TODO: improve light theme
  static ThemeData lightTheme() {
    return FlexThemeData.light(
      scheme: scheme,
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
      cardColor: lightCardBackground,
      appBarTheme: const AppBarTheme(
        scrolledUnderElevation: 0,
        elevation: 0,
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: Colors.white,
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
          borderSide: BorderSide(
            color: scheme.data.light.primary,
            width: 3,
          ),
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
