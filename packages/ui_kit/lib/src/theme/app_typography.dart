import 'package:flutter/material.dart';

/// Defines the font families used throughout the application.
class FontFamily {
  /// The Nunito font family.
  static const nunito = 'packages/ui_kit/Nunito';

  /// The main font family used in the application.
  static const String main = nunito;
}

/// Defines text styles used throughout the application.
abstract class AppTextStyle {
  static const _headline = TextStyle(
    fontFamily: FontFamily.nunito,
    fontWeight: FontWeight.w600,
    letterSpacing: 0,
    decoration: TextDecoration.none,
    textBaseline: TextBaseline.alphabetic,
  );

  static const _main = TextStyle(
    fontFamily: FontFamily.nunito,
    letterSpacing: 0,
    decoration: TextDecoration.none,
    textBaseline: TextBaseline.alphabetic,
  );

  // When height is non-null, the line height of the span of text will be a
  // multiple of font Size and be exactly fontSize * height logical pixels tall.

  // For example, if want to have height 24.0, with font-size 20.0, we should
  // have height property 1.2

  /// Headline style with 60px font size.
  static final TextStyle h0 = _headline.copyWith(fontSize: 60, height: 1);

  /// Headline style with 48px font size.
  static final TextStyle h1 = _headline.copyWith(fontSize: 48, height: 1.1);

  /// Headline style with 40px font size.
  static final TextStyle h2 = _headline.copyWith(fontSize: 40, height: 1.2);

  /// Headline style with 36px font size.
  static final TextStyle h3 = _headline.copyWith(fontSize: 36, height: 1.1);

  /// Headline style with 32px font size.
  static final TextStyle h4 = _headline.copyWith(fontSize: 32, height: 1.3);

  /// Headline style with 24px font size.
  static final TextStyle h5 = _headline.copyWith(fontSize: 24, height: 1.3);

  /// Headline style with 20px font size.
  static final TextStyle h6 = _headline.copyWith(fontSize: 20, height: 1.2);

  /// Title style with 20px font size.
  static final TextStyle titleL = _headline.copyWith(
    fontSize: 20,
    fontWeight: FontWeight.w700,
  );

  /// Title style with 18px font size.
  static final TextStyle title = _headline.copyWith(fontSize: 18, height: 1.3);

  /// Medium title style with 16px font size and semibold weight.
  static final TextStyle titleM = _main.copyWith(fontSize: 16, fontWeight: FontWeight.w600);

  /// Small title style with 14px font size and semibold weight.
  static final TextStyle titleS = _main.copyWith(fontSize: 14, fontWeight: FontWeight.w600);

  /// Large button text style with 16px font size and bold weight.
  static final TextStyle buttonL = _main.copyWith(fontSize: 16, fontWeight: FontWeight.w700);

  /// Small button text style with 14px font size and bold weight.
  static final TextStyle buttonS = _main.copyWith(fontSize: 14, fontWeight: FontWeight.w600);

  /// Tab text style with 14px font size and semibold weight.
  static final TextStyle tab = _main.copyWith(fontSize: 14, fontWeight: FontWeight.w600);

  /// Large body text style with 14px font size and medium weight.
  static final TextStyle bodyL = _main.copyWith(fontSize: 14, fontWeight: FontWeight.w500);

  /// Standard body text style with 13px font size and medium weight.
  static final TextStyle body = _main.copyWith(fontSize: 13, fontWeight: FontWeight.w500);

  /// Bold body text style with 14px font size and bold weight.
  static final TextStyle bodyBold = _main.copyWith(fontSize: 14, fontWeight: FontWeight.w700);

  /// Regular body text style with 13px font size and normal weight.
  static final TextStyle bodyRegular = _main.copyWith(fontSize: 13);

  /// Large caption text style with 12px font size and medium weight.
  static final TextStyle captionL = _main.copyWith(fontSize: 12, fontWeight: FontWeight.w500);

  /// Small caption text style with 11px font size and medium weight.
  static final TextStyle captionS = _main.copyWith(fontSize: 11, fontWeight: FontWeight.w500);

  /// Pin field text style with 16px font size and semibold weight.
  static final TextStyle textField = _main.copyWith(fontSize: 16, fontWeight: FontWeight.w600);

  /// Chip text style with 14px font size, bold weight, and increased letter spacing.
  static final TextStyle chip = _main.copyWith(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    height: 1.2,
  );
}
