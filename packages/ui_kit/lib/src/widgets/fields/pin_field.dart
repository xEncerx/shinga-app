import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pinput/pinput.dart';
import 'package:ui_kit/ui_kit.dart';

/// A customizable PIN / OTP input field.
///
/// The appearance of each state can be customised through the corresponding
/// `*PinTheme` parameters. Any property left `null` in those theme objects
/// falls back to a sensible default derived from the active [ColorScheme].
class SaPinField extends StatelessWidget {
  /// Creates a [SaPinField] widget.
  const SaPinField({
    super.key,
    this.controller,
    this.focusNode,
    this.width = 42,
    this.height = 48,
    this.showError = false,
    this.enabled = true,
    this.focusedSizeFactor = 1.1,
    this.defaultPinTheme,
    this.focusedPinTheme,
    this.submittedPinTheme,
    this.errorPinTheme,
    this.disabledPinTheme,
    this.textStyle,
    this.length = 6,
    this.spacing,
    this.onCompleted,
    this.onChanged,
    this.onSubmitted,
    this.inputFormatters = const [],
    this.keyboardType = TextInputType.number,
    this.cursorBuilder,
  });

  /// Number of individual PIN cells (digits). Defaults to `6`.
  final int length;

  /// Width of a single cell in logical pixels. Defaults to `42`.
  final double width;

  /// Height of a single cell in logical pixels. Defaults to `48`.
  final double height;

  /// Whether to force the error state, showing the [errorPinTheme] and
  /// ignoring the current input. Useful for validating the PIN after submission.
  final bool showError;

  /// Whether the field is enabled.
  final bool enabled;

  /// Visual overrides for the **default** (unfocused, empty) cell state.
  final SaPinCellThemeData? defaultPinTheme;

  /// Visual overrides for the **focused** (active cursor) cell state.
  ///
  /// The focused cell is scaled up by [focusedSizeFactor] by default.
  final SaPinCellThemeData? focusedPinTheme;

  /// Visual overrides for the **submitted** (digit entered) cell state.
  final SaPinCellThemeData? submittedPinTheme;

  /// Visual overrides for the **error** cell state.
  ///
  /// Defaults to a red border using [ColorScheme.error].
  final SaPinCellThemeData? errorPinTheme;

  /// Visual overrides for the **disabled** (non-interactive) cell state.
  ///
  /// Defaults to a dimmed border at 40 % opacity.
  final SaPinCellThemeData? disabledPinTheme;

  /// Text style applied to the digit inside each cell.
  ///
  /// Falls back to [AppTextStyle.textField] when not specified.
  final TextStyle? textStyle;

  /// Uniform scale factor applied to the cell size when it is focused.
  ///
  /// A value of `1.1` (the default) makes the active cell 10 % larger
  /// than the rest, providing subtle visual feedback.
  final double focusedSizeFactor;

  /// Horizontal gap between adjacent cells in logical pixels.
  ///
  /// Defaults to [AppSpacing.s] when `null`.
  final double? spacing;

  /// Optional controller to read or manipulate the current PIN value.
  final TextEditingController? controller;

  /// Optional focus node to control keyboard focus programmatically.
  final FocusNode? focusNode;

  /// Additional input formatters applied to the underlying text field.
  final List<TextInputFormatter> inputFormatters;

  /// Called once when the user has entered all [length] digits.
  final ValueChanged<String>? onCompleted;

  /// Called whenever the PIN value changes, including intermediate states.
  final ValueChanged<String>? onChanged;

  /// Called when the user submits the field from the keyboard.
  final ValueChanged<String>? onSubmitted;

  /// Keyboard type shown when the field gains focus. Defaults to
  /// [TextInputType.number].
  final TextInputType keyboardType;

  /// Custom widget rendered as the blinking cursor inside the focused cell.
  ///
  /// When `null`, a thin 18 × 1.8 px bar aligned to the cell bottom is used.
  final Widget? cursorBuilder;

  static const double _defaultCellBorderRadius = AppRadius.l;
  static const double _defaultCellBorderWidth = 1;
  static const double _defaultSelectedCellBorderWidth = 1.3;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final cursorColor = colorScheme.secondary;

    final defaultPinTheme = _defaultPinTheme(colorScheme);
    return SizedBox(
      width: width * focusedSizeFactor * length + (spacing ?? AppSpacing.s) * (length - 1),
      height: height * focusedSizeFactor,
      child: Pinput(
        length: length,
        controller: controller,
        focusNode: focusNode,
        enabled: enabled,
        defaultPinTheme: defaultPinTheme,
        focusedPinTheme: _focusedPinTheme(defaultPinTheme, colorScheme),
        submittedPinTheme: _submittedPinTheme(defaultPinTheme, colorScheme),
        disabledPinTheme: _disabledPinTheme(defaultPinTheme, colorScheme),
        errorPinTheme: _errorPinTheme(defaultPinTheme, colorScheme),
        separatorBuilder: (_) => SizedBox(width: spacing ?? AppSpacing.s),
        cursor: cursorBuilder ?? _cursor(cursorColor),
        inputFormatters: inputFormatters,
        keyboardType: keyboardType,
        onChanged: onChanged,
        onCompleted: onCompleted,
        onSubmitted: onSubmitted,
        forceErrorState: showError,
      ),
    );
  }

  /// Builds the base [PinTheme] used as a starting point for all states.
  PinTheme _defaultPinTheme(ColorScheme colorScheme) {
    final themeData = defaultPinTheme;

    return PinTheme(
      width: themeData?.width ?? width,
      height: themeData?.height ?? height,
      textStyle: textStyle ?? AppTextStyle.textField,
      decoration: BoxDecoration(
        color: themeData?.fillColor ?? Colors.transparent,
        borderRadius: BorderRadius.circular(themeData?.borderRadius ?? _defaultCellBorderRadius),
        border: Border.all(
          color: themeData?.borderColor ?? colorScheme.outline,
          width: themeData?.borderWidth ?? _defaultCellBorderWidth,
        ),
      ),
    );
  }

  /// Derives the focused-state theme from [base], scaling the cell up.
  PinTheme _focusedPinTheme(
    PinTheme base,
    ColorScheme colorScheme,
  ) {
    final themeData = focusedPinTheme;

    return base.copyWith(
      width: themeData?.width ?? width * focusedSizeFactor,
      height: themeData?.height ?? height * focusedSizeFactor,
      decoration: BoxDecoration(
        color: themeData?.fillColor,
        borderRadius: BorderRadius.circular(themeData?.borderRadius ?? _defaultCellBorderRadius),
        border: Border.all(
          color: themeData?.borderColor ?? colorScheme.secondary,
          width: themeData?.borderWidth ?? _defaultSelectedCellBorderWidth,
        ),
      ),
    );
  }

  /// Derives the submitted-state theme from [base].
  PinTheme _submittedPinTheme(
    PinTheme base,
    ColorScheme colorScheme,
  ) {
    final themeData = submittedPinTheme;

    return base.copyWith(
      width: themeData?.width,
      height: themeData?.height,
      decoration: BoxDecoration(
        color: themeData?.fillColor,
        borderRadius: BorderRadius.circular(themeData?.borderRadius ?? _defaultCellBorderRadius),
        border: Border.all(
          color: themeData?.borderColor ?? colorScheme.primary,
          width: themeData?.borderWidth ?? _defaultSelectedCellBorderWidth,
        ),
      ),
    );
  }

  /// Derives the disabled-state theme from [base] with a dimmed border.
  PinTheme _disabledPinTheme(
    PinTheme base,
    ColorScheme colorScheme,
  ) {
    final themeData = disabledPinTheme;

    return base.copyWith(
      width: themeData?.width ?? width,
      height: themeData?.height ?? height,
      decoration: BoxDecoration(
        color: themeData?.fillColor,
        borderRadius: BorderRadius.circular(themeData?.borderRadius ?? _defaultCellBorderRadius),
        border: Border.all(
          color: themeData?.borderColor ?? colorScheme.outline.withValues(alpha: 0.4),
          width: themeData?.borderWidth ?? _defaultSelectedCellBorderWidth,
        ),
      ),
    );
  }

  /// Derives the error-state theme from [base] using [ColorScheme.error].
  PinTheme _errorPinTheme(
    PinTheme base,
    ColorScheme colorScheme,
  ) {
    final themeData = errorPinTheme;

    return base.copyWith(
      width: themeData?.width,
      height: themeData?.height,
      decoration: BoxDecoration(
        color: themeData?.fillColor,
        borderRadius: BorderRadius.circular(themeData?.borderRadius ?? _defaultCellBorderRadius),
        border: Border.all(
          color: themeData?.borderColor ?? colorScheme.error,
          width: themeData?.borderWidth ?? _defaultSelectedCellBorderWidth,
        ),
      ),
    );
  }

  /// Returns the default cursor: a thin bar anchored to the cell bottom.
  Widget _cursor(Color color) => Align(
    alignment: Alignment.bottomCenter,
    child: Container(
      width: 18,
      height: 1.8,
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(1),
      ),
    ),
  );
}
