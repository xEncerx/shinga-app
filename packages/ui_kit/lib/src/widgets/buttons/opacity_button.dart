import 'package:flutter/material.dart';
import 'package:ui_kit/ui_kit.dart';

/// A custom button widget that provides an opacity effect.
class SaOpacityButton extends StatelessWidget {
  /// Creates a [SaOpacityButton] widget.
  const SaOpacityButton({
    required this.child,
    super.key,
    this.onPressed,
    this.onLongPress,
    this.width,
    this.height = 36,
    this.primaryColor,
    this.backgroundColor,
    this.foregroundColor,
    this.borderRadius,
    this.padding,
    this.border = BorderSide.none,
    this.elevation = 0,
  });

  /// Creates a [SaOpacityButton] with an icon and label.
  ///
  /// The [icon] and [label] are arranged in a row with spacing between them.
  /// If [icon] is null, this constructor creates a button without an icon.
  SaOpacityButton.icon({
    required Widget label,
    super.key,
    Widget? icon,
    SaIconAlignment iconAlignment = SaIconAlignment.start,
    this.onPressed,
    this.onLongPress,
    this.width,
    this.height = 36,
    this.primaryColor,
    this.backgroundColor,
    this.foregroundColor,
    this.borderRadius,
    this.padding,
    this.border = BorderSide.none,
    this.elevation = 0,
  }) : child = icon != null
           ? SaIconText(
               icon: icon,
               label: label,
               iconAlignment: iconAlignment,
             )
           : label;

  /// The fixed width of the button.
  ///
  /// When null the button sizes itself to its content along the main axis.
  final double? width;

  /// The fixed height of the button. Defaults to `48`.
  final double height;

  /// The callback when button is pressed.
  final VoidCallback? onPressed;

  /// The callback when button is long-pressed.
  final VoidCallback? onLongPress;

  /// The elevation of the button, producing a drop shadow.
  ///
  /// Defaults to `0` (no shadow).
  final double elevation;

  /// The primary color used for the button. Defaults to theme's primary color.
  final Color? primaryColor;

  /// The background color of the button.
  ///
  /// Defaults to primary color with 0.15 opacity.
  final Color? backgroundColor;

  /// The foreground color (text/icon color) of the button.
  final Color? foregroundColor;

  /// The corner radius of the button. Defaults to `12`.
  final BorderRadius? borderRadius;

  /// An optional border drawn around the button's perimeter.
  final BorderSide border;

  /// The internal padding of the button.
  ///
  /// Defaults to horizontal `AppSpacing.l` and vertical `AppSpacing.s`.
  final EdgeInsetsGeometry? padding;

  /// The widget to display inside the button.
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
    final colorScheme = context.colors;
    final pc = primaryColor ?? colorScheme.primary;

    final buttonStyle = _resolveStyle(colorScheme, pc);

    return Material(
      color: buttonStyle.bg,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: _effectiveBorderRadius,
        side: border,
      ),
      child: Ink(
        child: InkWell(
          onTap: onPressed,
          onLongPress: onLongPress,
          splashColor: buttonStyle.fg.splashColor(),
          highlightColor: buttonStyle.fg.highlightColor(),
          hoverColor: buttonStyle.fg.hoverColor(),
          mouseCursor: _isEnabled ? SystemMouseCursors.click : SystemMouseCursors.basic,
          child: Container(
            width: width,
            height: height,
            padding: _effectivePadding,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              boxShadow: _resolveShadow(pc),
            ),
            child: DefaultTextStyle(
              style: AppTextStyle.buttonS.copyWith(color: buttonStyle.fg),
              child: IconTheme(
                data: IconThemeData(color: buttonStyle.fg, size: 20),
                child: child,
              ),
            ),
          ),
        ),
      ),
    );
  }

  ({Color bg, Color fg}) _resolveStyle(
    ColorScheme colors,
    Color pc,
  ) {
    if (!_isEnabled) {
      return (
        bg: colors.onSurface.withValues(alpha: 0.12),
        fg: colors.onSurface.withValues(alpha: 0.38),
      );
    }

    return (
      bg: backgroundColor?.withValues(alpha: 0.15) ?? pc.withValues(alpha: 0.15),
      fg: foregroundColor ?? backgroundColor ?? pc,
    );
  }

  List<BoxShadow>? _resolveShadow(Color shadowColor) {
    if (elevation <= 0) return null;

    return [
      BoxShadow(
        color: shadowColor.withValues(alpha: 0.2),
        blurRadius: elevation,
        offset: Offset(0, elevation / 2),
      ),
    ];
  }
}
