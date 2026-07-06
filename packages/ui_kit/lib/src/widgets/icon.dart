import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';

/// A sealed class representing different icon sources for [SaIcon].
sealed class SaIconSource {
  /// Creates a [SaIconSource] instance.
  const SaIconSource();

  /// Creates a Material icon source from the given [icon].
  const factory SaIconSource.material(IconData icon) = _SaMaterialIcon;

  /// Creates a HugeIcons icon source from the given [icon] with optional [strokeWidth].
  const factory SaIconSource.huge(
    List<List<dynamic>> icon, {
    double? strokeWidth,
  }) = _SaHugeIcon;
}

/// A Material icon source implementation.
final class _SaMaterialIcon extends SaIconSource {
  const _SaMaterialIcon(this.icon);

  /// The Material icon data.
  final IconData icon;
}

/// A HugeIcons icon source implementation.
final class _SaHugeIcon extends SaIconSource {
  const _SaHugeIcon(this.icon, {this.strokeWidth});

  /// The Huge icon data.
  final List<List<dynamic>> icon;

  /// The optional stroke width for the icon.
  final double? strokeWidth;
}

/// A widget that displays an icon from various sources.
class SaIcon extends StatelessWidget {
  /// Creates a [SaIcon] widget.
  const SaIcon({
    required this.icon,
    super.key,
    this.size = 24.0,
    this.color,
  });

  /// The source of the icon to display.
  final SaIconSource icon;

  /// The optional size of the icon.
  final double? size;

  /// The optional color of the icon.
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final iconColor = color ?? IconTheme.of(context).color ?? Colors.black;

    return switch (icon) {
      _SaMaterialIcon(:final icon) => Icon(
        icon,
        size: size,
        color: iconColor,
      ),
      _SaHugeIcon(:final icon, :final strokeWidth) => HugeIcon(
        icon: icon,
        size: size,
        strokeWidth: strokeWidth,
        color: iconColor,
      ),
    };
  }
}
