import 'package:flutter/material.dart';

/// Defines the width thresholds used by responsive layouts.
abstract final class AppBreakpoints {
  /// The minimum width for tablet layouts.
  static const tablet = 600.0;

  /// The minimum width for desktop layouts.
  static const desktop = 840.0;
}

/// Represents the layout category for the current screen width.
enum AppScreenType {
  /// A phone-sized screen.
  phone,

  /// A tablet-sized screen.
  tablet,

  /// A desktop-sized screen.
  desktop,
}

/// Provides responsive layout information from the current [BuildContext].
extension ResponsiveContext on BuildContext {
  /// Returns the layout category for the current screen width.
  AppScreenType get screenType {
    final width = MediaQuery.sizeOf(this).width;

    if (width >= AppBreakpoints.desktop) {
      return AppScreenType.desktop;
    }

    if (width >= AppBreakpoints.tablet) {
      return AppScreenType.tablet;
    }

    return AppScreenType.phone;
  }

  /// Whether the current screen uses the phone layout.
  bool get isPhone => screenType == AppScreenType.phone;

  /// Whether the current screen uses the tablet layout.
  bool get isTablet => screenType == AppScreenType.tablet;

  /// Whether the current screen uses the desktop layout.
  bool get isDesktop => screenType == AppScreenType.desktop;

  /// Whether the current screen is at least tablet-sized.
  bool get isTabletOrLarger => !isPhone;
}
