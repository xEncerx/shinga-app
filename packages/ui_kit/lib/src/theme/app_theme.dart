import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ui_kit/src/theme/theme.dart';

/// Defines the application's themes, including both light and dark variants.
abstract final class AppTheme {
  static const FlexScheme _defaultScheme = FlexScheme.shadBlue;
  static const double _defaultRadius = AppRadius.defaultR;
  static const double _cardRadius = AppRadius.card;
  static const double _buttonRadius = AppRadius.button;
  static const double _textFieldRadius = AppRadius.xxl;
  static const double _snackBarRadius = AppRadius.l;
  static const double _chipColor = AppRadius.chip;

  /// Returns the dark theme for the application.
  static ThemeData darkTheme({FlexScheme scheme = _defaultScheme}) {
    return FlexThemeData.dark(
      scheme: scheme,
      appBarStyle: FlexAppBarStyle.scaffoldBackground,
      tabBarStyle: FlexTabBarStyle.forAppBar,
      useMaterial3ErrorColors: true,
      variant: FlexSchemeVariant.fidelity,
      keyColors: const FlexKeyColors(keepPrimary: true),
      subThemesData: const FlexSubThemesData(
        // Bottom Sheet
        bottomSheetModalBackgroundColor: SchemeColor.surface,
        // Dialogs
        dialogBackgroundSchemeColor: SchemeColor.surface,
        // Radius
        defaultRadius: _defaultRadius,
        cardRadius: _cardRadius,
        filledButtonRadius: _buttonRadius,
        elevatedButtonRadius: _buttonRadius,
        outlinedButtonRadius: _buttonRadius,
        // AppBar
        appBarCenterTitle: true,
        appBarScrolledUnderElevation: 0,
        // FAB
        fabUseShape: true,
        fabAlwaysCircular: true,
        // Chips
        chipRadius: _chipColor,
        chipPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        chipSchemeColor: SchemeColor.primary,
        // InputDecorator
        inputSelectionSchemeColor: SchemeColor.primary,
        inputSelectionHandleSchemeColor: SchemeColor.primary,
        inputDecoratorBorderSchemeColor: SchemeColor.primary,
        inputDecoratorPrefixIconSchemeColor: SchemeColor.primary,
        inputDecoratorSuffixIconSchemeColor: SchemeColor.primary,
        inputCursorSchemeColor: SchemeColor.primary,
        inputDecoratorRadius: _textFieldRadius,
        inputSelectionOpacity: 0.25,
        inputDecoratorBorderWidth: 0.8,
        inputDecoratorFocusedBorderWidth: 1.5,
        inputDecoratorIsFilled: false,
        inputDecoratorContentPadding: EdgeInsets.zero,
        inputDecoratorBorderType: FlexInputBorderType.outline,
        useInputDecoratorThemeInDialogs: true,
        // TabBar
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
        bottomNavigationBarBackgroundSchemeColor: SchemeColor.surface,
        // Switch
        switchThumbSchemeColor: SchemeColor.onPrimary,
        // Global
        alignedDropdown: true,
        navigationRailUseIndicator: true,
        interactionEffects: true,
        tintedDisabledControls: true,
        blendOnColors: true,
        unselectedToggleIsColored: true,
        useM2StyleDividerInM3: true,
      ),
      cupertinoOverrideTheme: const CupertinoThemeData(
        textTheme: CupertinoTextThemeData(
          textStyle: TextStyle(color: Colors.white),
        ),
        applyThemeToAll: true,
      ),
      visualDensity: FlexColorScheme.comfortablePlatformDensity,
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: CupertinoPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
          TargetPlatform.macOS: CupertinoPageTransitionsBuilder(),
          TargetPlatform.windows: ZoomPageTransitionsBuilder(),
          TargetPlatform.linux: ZoomPageTransitionsBuilder(),
          TargetPlatform.fuchsia: ZoomPageTransitionsBuilder(),
        },
      ),
      splashFactory: InkRipple.splashFactory,
      extensions: [AppColors.dark, LoggerColors.dark],
      fontFamily: FontFamily.main,
    ).copyWith(
      snackBarTheme: SnackBarThemeData(
        backgroundColor: Colors.white,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(_snackBarRadius),
        ),
        dismissDirection: DismissDirection.horizontal,
      ),
    );
  }

  /// Returns the light theme for the application.
  static ThemeData lightTheme({FlexScheme scheme = _defaultScheme}) {
    return FlexThemeData.light(
      scheme: scheme,
      appBarStyle: FlexAppBarStyle.scaffoldBackground,
      tabBarStyle: FlexTabBarStyle.forAppBar,
      useMaterial3ErrorColors: true,
      variant: FlexSchemeVariant.fidelity,
      keyColors: const FlexKeyColors(keepPrimary: true),
      subThemesData: const FlexSubThemesData(
        // Bottom Sheet
        bottomSheetModalBackgroundColor: SchemeColor.surface,
        // Dialogs
        dialogBackgroundSchemeColor: SchemeColor.surface,
        // Radius
        defaultRadius: _defaultRadius,
        cardRadius: _cardRadius,
        filledButtonRadius: _buttonRadius,
        elevatedButtonRadius: _buttonRadius,
        outlinedButtonRadius: _buttonRadius,
        // AppBar
        appBarCenterTitle: true,
        appBarScrolledUnderElevation: 0,
        // FAB
        fabUseShape: true,
        fabAlwaysCircular: true,
        // Chips
        chipRadius: _chipColor,
        chipPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        chipSchemeColor: SchemeColor.primary,
        // InputDecorator
        inputSelectionSchemeColor: SchemeColor.primary,
        inputSelectionHandleSchemeColor: SchemeColor.primary,
        inputDecoratorBorderSchemeColor: SchemeColor.primary,
        inputDecoratorPrefixIconSchemeColor: SchemeColor.primary,
        inputDecoratorSuffixIconSchemeColor: SchemeColor.primary,
        inputCursorSchemeColor: SchemeColor.primary,
        inputDecoratorRadius: _textFieldRadius,
        inputSelectionOpacity: 0.25,
        inputDecoratorBorderWidth: 0.8,
        inputDecoratorFocusedBorderWidth: 1.5,
        inputDecoratorIsFilled: false,
        inputDecoratorContentPadding: EdgeInsets.zero,
        inputDecoratorBorderType: FlexInputBorderType.outline,
        useInputDecoratorThemeInDialogs: true,
        // TabBar
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
        bottomNavigationBarBackgroundSchemeColor: SchemeColor.surface,
        // Switch
        switchThumbSchemeColor: SchemeColor.onPrimary,
        // Global
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
      visualDensity: FlexColorScheme.comfortablePlatformDensity,
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: CupertinoPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
          TargetPlatform.macOS: CupertinoPageTransitionsBuilder(),
          TargetPlatform.windows: ZoomPageTransitionsBuilder(),
          TargetPlatform.linux: ZoomPageTransitionsBuilder(),
          TargetPlatform.fuchsia: ZoomPageTransitionsBuilder(),
        },
      ),
      splashFactory: InkRipple.splashFactory,
      extensions: [AppColors.light, LoggerColors.light],
      fontFamily: FontFamily.main,
    ).copyWith(
      snackBarTheme: SnackBarThemeData(
        backgroundColor: Colors.white,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(_snackBarRadius),
        ),
        dismissDirection: DismissDirection.horizontal,
      ),
    );
  }
}
