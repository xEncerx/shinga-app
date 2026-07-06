import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:ui_kit/src/src.dart';

/// A widget that displays a shimmer effect.
class SaShimmer extends StatelessWidget {
  /// Creates a [SaShimmer] widget.
  const SaShimmer({
    super.key,
    this.baseColor,
    this.highlightColor,
    this.period = const Duration(seconds: 1),
    this.child,
  });

  /// The base color of the shimmer effect.
  ///
  /// If not provided, it defaults to a semi-transparent version of the primary color.
  final Color? baseColor;

  /// The highlight color of the shimmer effect.
  ///
  /// If not provided, it defaults to a slightly lighter version of the primary color.
  final Color? highlightColor;

  /// The duration of the shimmer animation.
  final Duration period;

  /// The child widget to which the shimmer effect will be applied.
  ///
  /// Defaults to a [ColoredBox] with the effective base color if not provided.
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    final primaryColor = colors.primary;
    final effectiveColor = baseColor ?? primaryColor.withValues(alpha: 0.3);

    return Shimmer.fromColors(
      baseColor: effectiveColor,
      highlightColor: highlightColor ?? Color.lerp(primaryColor, Colors.white, 0.1)!,
      period: period,
      child:
          child ??
          SizedBox.expand(
            child: ColoredBox(color: effectiveColor),
          ),
    );
  }
}
