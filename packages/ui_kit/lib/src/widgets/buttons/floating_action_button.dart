import 'package:flutter/material.dart';
import 'package:ui_kit/ui_kit.dart';

/// A circular action button, similar to a [FloatingActionButton].
///
/// When [isLoading] is `true`, the button is non-interactive and its [child]
/// is replaced by a [CircularProgressIndicator].
class SaFloatingActionButton extends StatelessWidget {
  /// Creates a [SaFloatingActionButton] widget.
  const SaFloatingActionButton({
    required this.child,
    super.key,
    this.size = 56.0,
    this.onPressed,
    this.onLongPress,
    this.isLoading,
    this.elevation = 6.0,
    this.backgroundColor,
    this.foregroundColor,
    this.padding,
  });

  /// The diameter of the circular button. Defaults to `56.0` (standard FAB size).
  final double size;

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
  /// Defaults to `6.0`.
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

  /// The internal padding of the button.
  final EdgeInsetsGeometry? padding;

  /// The widget displayed inside the button.
  ///
  /// Replaced by a [CircularProgressIndicator] when [isLoading] is `true`.
  final Widget child;

  bool get _isLoading => isLoading ?? false;
  bool get _isEnabled => !_isLoading && (onPressed != null || onLongPress != null);

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colors;
    final pc = backgroundColor ?? colorScheme.primary;

    final buttonStyle = _resolveStyle(context, pc);

    return Material(
      type: MaterialType.circle,
      color: buttonStyle.bg,
      elevation: _isEnabled ? elevation : 0,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: _isEnabled ? onPressed : null,
        onLongPress: _isEnabled ? onLongPress : null,
        splashColor: buttonStyle.fg.splashColor(),
        highlightColor: buttonStyle.fg.highlightColor(),
        hoverColor: buttonStyle.fg.hoverColor(),
        mouseCursor: _isEnabled ? SystemMouseCursors.click : SystemMouseCursors.basic,
        child: Container(
          width: size,
          height: size,
          padding: padding,
          alignment: Alignment.center,
          child: DefaultTextStyle(
            style: AppTextStyle.buttonS.copyWith(color: buttonStyle.fg),
            child: IconTheme(
              data: IconThemeData(color: buttonStyle.fg),
              child: _isLoading
                  ? SizedBox(
                      width: size * 0.4, // Scale progress indicator to button size
                      height: size * 0.4,
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
