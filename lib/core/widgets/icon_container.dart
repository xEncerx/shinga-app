import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';

/// A customizable container widget that displays an icon with various styling options.
class IconContainer extends StatelessWidget {
  /// Creates a rectangular [IconContainer] with customizable shape
  const IconContainer({
    super.key,
    required this.icon,
    this.color,
    this.backgroundColor,
    this.size = 40.0,
    this.iconSize,
    this.borderRadius = 12.0,
    this.padding,
    this.border,
    this.borderColor,
    this.borderWidth = 1.0,
    this.backgroundOpacity = 0.15,
    this.shadows,
    this.gradient,
    this.onTap,
  });

  /// Icon to display. Can be either IconData or HugeIconData
  final Object icon;

  /// Color of the icon. If not specified, the primary color of the theme is used
  final Color? color;

  /// Background color of the container. If not specified, the icon color with opacity is used
  final Color? backgroundColor;

  /// Size of the container (width and height)
  final double size;

  /// Size of the icon
  final double? iconSize;

  /// Radius of the container's corners. If null, the container will be circular
  final double? borderRadius;

  /// Internal padding. If not specified, it is calculated automatically
  final EdgeInsetsGeometry? padding;

  /// Border of the container
  final Border? border;

  /// Color of the border. Used only if border is not specified
  final Color? borderColor;

  /// Thickness of the border
  final double borderWidth;

  /// Background opacity (used if backgroundColor is not specified)
  final double backgroundOpacity;

  /// Shadows of the container
  final List<BoxShadow>? shadows;

  /// Background gradient (takes priority over backgroundColor)
  final Gradient? gradient;

  /// Callback for tap events
  final VoidCallback? onTap;

  /// Builds the icon widget based on the icon type
  Widget _buildIconWidget(Color effectiveColor, double effectiveIconSize) {
    if (icon is IconData) {
      return Icon(
        icon as IconData,
        color: effectiveColor,
        size: effectiveIconSize,
      );
    } else if (icon is List<List<dynamic>>) {
      return HugeIcon(
        icon: icon as List<List<dynamic>>,
        color: effectiveColor,
        size: effectiveIconSize,
      );
    }
    
    // Fallback: if the icon type is neither IconData or HugeIconData, throw an error
    throw ArgumentError(
      'Icon must be either IconData or HugeIconData, but received ${icon.runtimeType}',
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final effectiveColor = color ?? theme.colorScheme.primary;
    final effectiveBackgroundColor =
        backgroundColor ?? effectiveColor.withValues(alpha: backgroundOpacity);

    final effectiveIconSize = iconSize ?? size * 0.6;

    final effectivePadding = padding ?? EdgeInsets.all((size - effectiveIconSize) / 2.2);

    final borderRadiusGeometry = borderRadius != null
        ? BorderRadius.circular(borderRadius!)
        : BorderRadius.circular(size / 2);

    final effectiveBorder =
        border ??
        (borderColor != null && borderWidth > 0
            ? Border.all(
                color: borderColor!,
                width: borderWidth,
              )
            : null);

    final decoration = BoxDecoration(
      color: gradient == null ? effectiveBackgroundColor : null,
      gradient: gradient,
      borderRadius: borderRadiusGeometry,
      border: effectiveBorder,
      boxShadow: shadows,
    );

    final iconWidget = _buildIconWidget(effectiveColor, effectiveIconSize);

    final containerWidget = Container(
      width: size,
      height: size,
      padding: effectivePadding,
      decoration: decoration,
      child: iconWidget,
    );

    if (onTap != null) {
      return Material(
        color: Colors.transparent,
        borderRadius: borderRadiusGeometry,
        child: InkWell(
          onTap: onTap,
          borderRadius: borderRadiusGeometry,
          child: containerWidget,
        ),
      );
    }

    return containerWidget;
  }
}
