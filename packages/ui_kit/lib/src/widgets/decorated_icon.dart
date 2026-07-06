import 'package:flutter/material.dart';
import 'package:ui_kit/ui_kit.dart';

/// A decorative container that displays an icon with a colored background.
class SaDecoratedIcon extends StatelessWidget {
  /// Creates a [SaDecoratedIcon] widget.
  const SaDecoratedIcon({
    required this.icon,
    super.key,
    this.iconColor,
    this.iconSize = 24.0,
    this.backgroundColor,
    this.borderRadius,
    this.borderColor,
    this.borderWidth = 1.0,
    this.shape = BoxShape.rectangle,
    this.padding,
  });

  /// The icon source to display.
  final SaIconSource icon;

  /// The size of the icon in logical pixels.
  final double iconSize;

  /// The color of the icon.
  ///
  /// Defaults to primary theme color if not specified.
  final Color? iconColor;

  /// The background color of the container.
  ///
  /// Defaults to [iconColor] with 15% opacity if not specified.
  final Color? backgroundColor;

  /// The border radius for rectangular shapes.
  ///
  /// Only applied when [shape] is [BoxShape.rectangle].
  final double? borderRadius;

  /// The color of the border around the container.
  final Color? borderColor;

  /// The width of the border around the container.
  final double borderWidth;

  /// The shape of the container.
  ///
  /// Can be either [BoxShape.rectangle] or [BoxShape.circle].
  final BoxShape shape;

  /// The padding around the icon.
  ///
  /// Defaults to 1/3 of [iconSize] if not specified.
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    final mainIconColor = iconColor ?? context.colors.primary;
    final shapeBgColor = backgroundColor ?? mainIconColor.withValues(alpha: 0.15);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: shapeBgColor,
        border: Border.all(
          color: borderColor ?? Colors.transparent,
          width: borderWidth,
        ),
        borderRadius: shape == BoxShape.rectangle
            ? BorderRadius.circular(borderRadius ?? AppRadius.l)
            : null,
        shape: shape,
      ),
      child: Padding(
        padding: padding ?? EdgeInsets.all(iconSize / 3),
        child: SaIcon(
          icon: icon,
          color: mainIconColor,
          size: iconSize,
        ),
      ),
    );
  }
}
