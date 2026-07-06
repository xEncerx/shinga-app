import 'package:flutter/material.dart';
import 'package:ui_kit/ui_kit.dart';

/// Defines the visual appearance of a single PIN cell in [SaPinField].
///
/// Pass instances of this class to [SaPinField] state-specific theme
/// parameters (e.g. [SaPinField.focusedPinTheme]) to override the
/// corresponding default values for that state only. Any `null` property
/// falls back to the [SaPinField] default.
class SaPinCellThemeData {
  /// Creates a [SaPinCellThemeData] instance.
  const SaPinCellThemeData({
    this.width,
    this.height,
    this.fillColor,
    this.borderColor,
    this.borderWidth,
    this.borderRadius,
  });

  /// Cell width in logical pixels. Defaults to [SaPinField.width].
  final double? width;

  /// Cell height in logical pixels. Defaults to [SaPinField.height].
  final double? height;

  /// Background fill color of the cell.
  final Color? fillColor;

  /// Color of the cell border.
  final Color? borderColor;

  /// Thickness of the cell border in logical pixels.
  final double? borderWidth;

  /// Corner radius of the cell border.
  final double? borderRadius;
}
