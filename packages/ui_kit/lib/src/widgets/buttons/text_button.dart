import 'package:flutter/material.dart';
import 'package:ui_kit/ui_kit.dart';

/// A text-only button with no background or elevation.
///
/// Renders [child] in the theme's primary color (or [foregroundColor]) without
/// a filled background, making it suitable for secondary / inline actions.
class SaTextButton extends StatelessWidget {
  /// Creates a [SaTextButton] widget.
  const SaTextButton({
    required this.child,
    super.key,
    this.onPressed,
    this.onLongPress,
    this.foregroundColor,
    this.borderRadius,
    this.padding,
  });

  /// Creates a [SaTextButton] with an icon and label.
  ///
  /// The [icon] and [label] are arranged in a row with spacing between them.
  /// If [icon] is null, this constructor creates a button without an icon.
  SaTextButton.icon({
    required Widget label,
    super.key,
    Widget? icon,
    SaIconAlignment iconAlignment = SaIconAlignment.start,
    this.onPressed,
    this.onLongPress,
    this.foregroundColor,
    this.borderRadius,
    this.padding,
  }) : child = icon != null
           ? SaIconText(
               icon: icon,
               label: label,
               iconAlignment: iconAlignment,
             )
           : label;

  /// Called when the button is pressed.
  final VoidCallback? onPressed;

  /// Called when the button is long-pressed.
  final VoidCallback? onLongPress;

  /// The color applied to text and icons inside the button.
  ///
  /// Defaults to the theme's `primary` color when null.
  final Color? foregroundColor;

  /// The corner radius of the button. Defaults to `12`.
  final BorderRadius? borderRadius;

  /// The internal padding of the button.
  ///
  /// Defaults to horizontal [AppSpacing.l] and vertical [AppSpacing.s].
  final EdgeInsetsGeometry? padding;

  /// The widget displayed inside the button.
  final Widget child;

  bool get _isEnabled => onPressed != null || onLongPress != null;

  BorderRadius get _effectiveBorderRadius =>
      borderRadius ?? BorderRadius.circular(AppRadius.button);

  EdgeInsetsGeometry get _effectivePadding =>
      padding ??
      const EdgeInsets.symmetric(
        horizontal: AppSpacing.l,
        vertical: AppSpacing.s,
      );

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final fg = foregroundColor ?? colors.primary;

    return Material(
      color: Colors.transparent,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: _effectiveBorderRadius),
      child: InkWell(
        onTap: _isEnabled ? onPressed : null,
        onLongPress: _isEnabled ? onLongPress : null,
        splashColor: fg.splashColor(),
        highlightColor: fg.highlightColor(),
        hoverColor: fg.hoverColor(),
        mouseCursor: _isEnabled ? SystemMouseCursors.click : SystemMouseCursors.basic,
        child: Padding(
          padding: _effectivePadding,
          child: DefaultTextStyle(
            style: AppTextStyle.buttonS.copyWith(color: fg),
            child: IconTheme(
              data: IconThemeData(color: fg, size: 20),
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}
