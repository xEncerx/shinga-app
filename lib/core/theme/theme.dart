import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class AppTheme {
  static const Color darkBackground = Color(0xFF181C25);
  static const Color darkCardBackground = Color(0xFF303642);
  static const Color readingHighLight = Color(0xFF7C0DEC);
  static const Color completedHighLight = Color(0xFFE87C00);
  static const Color plannedHighLight = Color(0xFF0B64ED);
  static const Color droppedHighLight = Color(0xFF850001);

  static final bool isMobile =
      defaultTargetPlatform == TargetPlatform.android ||
      defaultTargetPlatform == TargetPlatform.iOS;

  static ThemeData darkTheme({FlexScheme scheme = FlexScheme.shadBlue}) {
    return FlexThemeData.dark(
      scheme: scheme,
      scaffoldBackground: darkBackground,
      dialogBackground: darkBackground,
      appBarStyle: FlexAppBarStyle.scaffoldBackground,
      tabBarStyle: FlexTabBarStyle.forAppBar,
      useMaterial3ErrorColors: true,
      subThemesData: const FlexSubThemesData(
        // FAB
        fabUseShape: true,
        fabAlwaysCircular: true,
        // Chips
        chipBlendColors: true,
        chipRadius: 30,
        chipPadding: EdgeInsets.symmetric(horizontal: 6, vertical: 4),
        chipSchemeColor: SchemeColor.primary,
        // InputDecorator
        inputCursorSchemeColor: SchemeColor.primary,
        inputDecoratorSchemeColor: SchemeColor.onTertiaryFixed,
        inputDecoratorIsFilled: true,
        inputDecoratorIsDense: true,
        inputDecoratorBackgroundAlpha: 130,
        inputDecoratorBorderSchemeColor: SchemeColor.primary,
        inputDecoratorBorderType: FlexInputBorderType.outline,
        inputDecoratorRadius: 12,
        inputDecoratorUnfocusedHasBorder: false,
        inputDecoratorPrefixIconSchemeColor: SchemeColor.onPrimaryFixedVariant,
        inputDecoratorSuffixIconSchemeColor: SchemeColor.onPrimaryFixedVariant,
        useInputDecoratorThemeInDialogs: true,
        inputDecoratorFocusedHasBorder: false,
        // TabBat
        tabBarDividerColor: Colors.transparent,
        tabBarItemSchemeColor: SchemeColor.primary,
        tabBarTabAlignment: TabAlignment.center,
        tabBarIndicatorSchemeColor: SchemeColor.primary,
        tabBarIndicatorSize: TabBarIndicatorSize.tab,
        tabBarIndicatorWeight: 3,
        tabBarIndicatorAnimation: TabIndicatorAnimation.linear,
        // BottomNavigation Bar
        bottomNavigationBarMutedUnselectedIcon: true,
        bottomNavigationBarMutedUnselectedLabel: true,
        bottomNavigationBarShowUnselectedLabels: false,
        bottomNavigationBarBackgroundSchemeColor: SchemeColor.secondaryContainer,
        // Switch
        switchThumbSchemeColor: SchemeColor.onPrimary,

        alignedDropdown: true,
        navigationRailUseIndicator: true,
        interactionEffects: true,
        tintedDisabledControls: true,
        blendOnColors: true,
        unselectedToggleIsColored: true,
        useM2StyleDividerInM3: true,
      ),
      cupertinoOverrideTheme: const CupertinoThemeData(
        applyThemeToAll: true,
      ),
      visualDensity: VisualDensity.compact,
      pageTransitionsTheme: PageTransitionsTheme(
        builders: {
          for (final platform in TargetPlatform.values)
            platform: const CupertinoPageTransitionsBuilder(),
        },
      ),
      splashFactory: InkRipple.splashFactory,
      fontFamily: "Nunito",
    ).copyWith(
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
    );
  }

  static ThemeData lightTheme({FlexScheme scheme = FlexScheme.shadBlue}) {
    return FlexThemeData.light(
      scheme: scheme,
      appBarStyle: FlexAppBarStyle.scaffoldBackground,
      tabBarStyle: FlexTabBarStyle.forAppBar,
      useMaterial3ErrorColors: true,
      subThemesData: const FlexSubThemesData(
        // FAB
        fabUseShape: true,
        fabAlwaysCircular: true,
        // Chips
        chipBlendColors: true,
        chipRadius: 30,
        chipPadding: EdgeInsets.symmetric(horizontal: 6, vertical: 4),
        chipSchemeColor: SchemeColor.primary,
        // InputDecorator
        inputCursorSchemeColor: SchemeColor.primary,
        inputDecoratorSchemeColor: SchemeColor.onTertiaryFixed,
        inputDecoratorIsFilled: true,
        inputDecoratorIsDense: true,
        inputDecoratorBackgroundAlpha: 130,
        inputDecoratorBorderSchemeColor: SchemeColor.primary,
        inputDecoratorBorderType: FlexInputBorderType.outline,
        inputDecoratorRadius: 12,
        inputDecoratorUnfocusedHasBorder: false,
        inputDecoratorPrefixIconSchemeColor: SchemeColor.onPrimaryFixedVariant,
        inputDecoratorSuffixIconSchemeColor: SchemeColor.onPrimaryFixedVariant,
        useInputDecoratorThemeInDialogs: true,
        inputDecoratorFocusedHasBorder: false,
        // TabBat
        tabBarDividerColor: Colors.transparent,
        tabBarItemSchemeColor: SchemeColor.primary,
        tabBarTabAlignment: TabAlignment.center,
        tabBarIndicatorSchemeColor: SchemeColor.primary,
        tabBarIndicatorSize: TabBarIndicatorSize.tab,
        tabBarIndicatorWeight: 3,
        tabBarIndicatorAnimation: TabIndicatorAnimation.linear,
        // BottomNavigation Bar
        bottomNavigationBarMutedUnselectedIcon: true,
        bottomNavigationBarMutedUnselectedLabel: true,
        bottomNavigationBarShowUnselectedLabels: false,
        bottomNavigationBarBackgroundSchemeColor: SchemeColor.secondaryContainer,
        // Switch
        switchThumbSchemeColor: SchemeColor.onPrimary,

        alignedDropdown: true,
        navigationRailUseIndicator: true,
        interactionEffects: true,
        tintedDisabledControls: true,
        blendOnColors: true,
        unselectedToggleIsColored: true,
        useM2StyleDividerInM3: true,
      ),
      cupertinoOverrideTheme: const CupertinoThemeData(
        applyThemeToAll: true,
      ),
      visualDensity: VisualDensity.compact,
      pageTransitionsTheme: PageTransitionsTheme(
        builders: {
          for (final platform in TargetPlatform.values)
            platform: const CupertinoPageTransitionsBuilder(),
        },
      ),
      splashFactory: InkRipple.splashFactory,
      fontFamily: "Nunito",
    ).copyWith(
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
    );
  }
}
