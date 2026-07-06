import 'package:flutter/material.dart';

/// A theme extension for custom color palette used throughout the app.
@immutable
class AppColors extends ThemeExtension<AppColors> {
  /// Creates an [AppColors] instance.
  const AppColors({
    required this.grey,
    required this.lightGreen,
    required this.warning,
    required this.onWarning,
    required this.success,
    required this.onSuccess,
    required this.bookmarkDropped,
    required this.bookmarkReading,
    required this.bookmarkCompleted,
    required this.bookmarkPlanning,
    required this.ratingColor,
  });

  /// The grey color.
  final Color grey;

  /// The light green color.
  final Color lightGreen;

  /// The color for dropped bookmark status.
  final Color bookmarkDropped;

  /// The color for reading bookmark status.
  final Color bookmarkReading;

  /// The color for completed bookmark status.
  final Color bookmarkCompleted;

  /// The color for planning bookmark status.
  final Color bookmarkPlanning;

  /// The color used for ratings.
  final Color ratingColor;

  /// The color for warning state messages.
  final Color warning;

  /// The color for text/icons on warning state messages.
  final Color onWarning;

  /// The color for error state messages.
  final Color success;

  /// The color for text/icons on error state messages.
  final Color onSuccess;

  /// The light theme color palette.
  static const light = AppColors(
    grey: Color(0xFF616161),
    lightGreen: Color(0xFF15B569),
    warning: Color(0xFF8C4D00),
    onWarning: Color(0xFFFFDDBE),
    success: Color(0xFFC8E6C9),
    onSuccess: Color(0xFF1B5E20),
    bookmarkDropped: Color(0xFF990100),
    bookmarkReading: Color(0xFF1D74FF),
    bookmarkCompleted: Color(0xFFFFA800),
    bookmarkPlanning: Color(0xFF9933FF),
    ratingColor: Color(0xFFE65000),
  );

  /// The dark theme color palette.
  static const dark = AppColors(
    grey: Color(0xFFBDBDBD),
    lightGreen: Color(0xFF15B569),
    warning: Color(0xFFF5C52F),
    onWarning: Color(0xFF5D4037),
    success: Color(0xFF2E7D32),
    onSuccess: Color(0xFFC3F7B9),
    bookmarkDropped: Color(0xFFE53935),
    bookmarkReading: Color(0xFF1E88E5),
    bookmarkCompleted: Color(0xFFFFB300),
    bookmarkPlanning: Color(0xFF8E24AA),
    ratingColor: Color(0xFFE59000),
  );

  @override
  /// Creates a copy of this [AppColors] with the given fields replaced.
  ThemeExtension<AppColors> copyWith({
    Color? grey,
    Color? lightGreen,
    Color? warning,
    Color? onWarning,
    Color? success,
    Color? onSuccess,
    Color? bookmarkDropped,
    Color? bookmarkReading,
    Color? bookmarkCompleted,
    Color? bookmarkPlanning,
    Color? bookmarkNotSet,
    Color? ratingColor,
  }) {
    return AppColors(
      grey: grey ?? this.grey,
      lightGreen: lightGreen ?? this.lightGreen,
      warning: warning ?? this.warning,
      onWarning: onWarning ?? this.onWarning,
      success: success ?? this.success,
      onSuccess: onSuccess ?? this.onSuccess,
      bookmarkDropped: bookmarkDropped ?? this.bookmarkDropped,
      bookmarkReading: bookmarkReading ?? this.bookmarkReading,
      bookmarkCompleted: bookmarkCompleted ?? this.bookmarkCompleted,
      bookmarkPlanning: bookmarkPlanning ?? this.bookmarkPlanning,
      ratingColor: ratingColor ?? this.ratingColor,
    );
  }

  @override
  /// Linearly interpolates between this [AppColors] and [other] by [t].
  ThemeExtension<AppColors> lerp(ThemeExtension<AppColors>? other, double t) {
    if (other is! AppColors) {
      return this;
    }
    return AppColors(
      grey: Color.lerp(grey, other.grey, t)!,
      lightGreen: Color.lerp(lightGreen, other.lightGreen, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      onWarning: Color.lerp(onWarning, other.onWarning, t)!,
      success: Color.lerp(success, other.success, t)!,
      onSuccess: Color.lerp(onSuccess, other.onSuccess, t)!,
      bookmarkDropped: Color.lerp(bookmarkDropped, other.bookmarkDropped, t)!,
      bookmarkReading: Color.lerp(bookmarkReading, other.bookmarkReading, t)!,
      bookmarkCompleted: Color.lerp(bookmarkCompleted, other.bookmarkCompleted, t)!,
      bookmarkPlanning: Color.lerp(bookmarkPlanning, other.bookmarkPlanning, t)!,
      ratingColor: Color.lerp(ratingColor, other.ratingColor, t)!,
    );
  }
}
