import 'package:flutter/material.dart';
import 'package:ui_kit/ui_kit.dart';

/// A primary action button with a solid background and ink ripple effect.
///
/// The [foregroundColor] is automatically derived from [backgroundColor]
/// luminance when not provided, ensuring accessible contrast at all times.
///
/// When [isLoading] is `true`, the button is non-interactive and its [child]
/// is replaced by a [CircularProgressIndicator].
class SaPrimaryButton extends StatelessWidget {
  /// Creates a [SaPrimaryButton] widget.
  const SaPrimaryButton({
    required this.child,
    super.key,
    this.width,
    this.height = 42,
    this.onPressed,
    this.onLongPress,
    this.isLoading,
    this.elevation = 3,
    this.backgroundColor,
    this.foregroundColor,
    this.borderRadius,
    this.border = BorderSide.none,
    this.padding,
  });

  /// Creates a [SaPrimaryButton] with an icon and label.
  ///
  /// The [icon] and [label] are arranged in a row with spacing between them.
  /// If [icon] is null, this constructor creates a button without an icon.
  SaPrimaryButton.icon({
    required Widget label,
    super.key,
    Widget? icon,
    SaIconAlignment iconAlignment = SaIconAlignment.start,
    this.width,
    this.height = 42,
    this.onPressed,
    this.onLongPress,
    this.isLoading,
    this.elevation = 3,
    this.backgroundColor,
    this.foregroundColor,
    this.borderRadius,
    this.border = BorderSide.none,
    this.padding,
  }) : child = icon != null
           ? SaIconText(icon: icon, label: label, iconAlignment: iconAlignment)
           : label;

  /// The fixed width of the button.
  ///
  /// When null the button sizes itself to its content along the main axis.
  final double? width;

  /// The fixed height of the button. Defaults to `36`.
  final double height;

  /// Called when the button is pressed.
  ///
  /// The button is considered disabled when both [onPressed] and [onLongPress]
  /// are null and [isLoading] is not `true`.
  final VoidCallback? onPressed;

  /// Called when the button is long-pressed.
  final VoidCallback? onLongPress;

  /// Whether the button is in a loading state.
  ///
  /// When `true`, [child] is replaced by a [CircularProgressIndicator] and the
  /// button ignores all interaction. The background color is preserved so the
  /// layout remains stable.
  final bool? isLoading;

  /// The elevation of the button, producing a drop shadow.
  ///
  /// Defaults to `3`.
  final double elevation;

  /// The solid fill color of the button.
  ///
  /// Defaults to the theme's `primary` color when null.
  final Color? backgroundColor;

  /// The color applied to text and icons inside the button.
  ///
  /// When null, computed automatically from [backgroundColor] luminance:
  /// a luminance above `0.5` yields a dark foreground; otherwise white.
  final Color? foregroundColor;

  /// The corner radius of the button. Defaults to `12`.
  final BorderRadius? borderRadius;

  /// An optional border drawn around the button's perimeter.
  final BorderSide border;

  /// The internal padding of the button.
  ///
  /// Defaults to horizontal `AppSpacing.l` and vertical `AppSpacing.s`.
  final EdgeInsetsGeometry? padding;

  /// The widget displayed inside the button.
  ///
  /// Replaced by a [CircularProgressIndicator] when [isLoading] is `true`.
  final Widget child;

  bool get _isLoading => isLoading ?? false;
  bool get _isEnabled => !_isLoading && (onPressed != null || onLongPress != null);

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
    final pc = backgroundColor ?? colorScheme.primary;

    final buttonStyle = _resolveStyle(context, pc);

    return Material(
      color: buttonStyle.bg,
      elevation: _isEnabled ? elevation : 0,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: _effectiveBorderRadius,
        side: border,
      ),
      child: InkWell(
        onTap: _isEnabled ? onPressed : null,
        onLongPress: _isEnabled ? onLongPress : null,
        splashColor: buttonStyle.fg.splashColor(),
        highlightColor: buttonStyle.fg.highlightColor(),
        hoverColor: buttonStyle.fg.hoverColor(),
        mouseCursor: _isEnabled ? SystemMouseCursors.click : SystemMouseCursors.basic,
        child: Container(
          width: width,
          height: height,
          padding: _effectivePadding,
          alignment: Alignment.center,
          child: DefaultTextStyle(
            style: AppTextStyle.buttonS.copyWith(color: buttonStyle.fg),
            child: IconTheme(
              data: IconThemeData(color: buttonStyle.fg),
              child: _isLoading
                  ? SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        valueColor: AlwaysStoppedAnimation<Color>(buttonStyle.fg),
                      ),
                    )
                  : child,
            ),
          ),
        ),
      ),
    );
  }

  ({Color bg, Color fg}) _resolveStyle(
    BuildContext context,
    Color bg,
  ) {
    final colors = context.colors;

    if (!_isEnabled && !_isLoading) {
      return (
        bg: colors.onSurface.withValues(alpha: 0.12),
        fg: colors.onSurface.withValues(alpha: 0.38),
      );
    }

    final resolvedBg = _isLoading ? bg.withValues(alpha: 0.7) : bg;
    final resolvedFg = foregroundColor ?? bg.foreground(context);

    return (
      bg: resolvedBg,
      fg: _isLoading ? resolvedFg.withValues(alpha: 0.7) : resolvedFg,
    );
  }
}
