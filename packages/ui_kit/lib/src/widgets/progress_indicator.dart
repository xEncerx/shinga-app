import 'dart:async';

import 'package:flutter/material.dart';
import 'package:ui_kit/ui_kit.dart';

/// Defines the color options for the [SaProgressIndicator].
sealed class SaProgressColor {
  const SaProgressColor();

  /// Creates a solid color option for the progress indicator.
  const factory SaProgressColor.solid(Color color, {Color? trackColor}) = _SolidProgressColor;

  /// Creates a gradient color option for the progress indicator.
  const factory SaProgressColor.gradient(Gradient gradient, {Color? trackColor}) =
      _GradientProgressColor;
}

final class _SolidProgressColor extends SaProgressColor {
  const _SolidProgressColor(this.color, {this.trackColor});

  final Color color;

  /// Optional track color for solid progress. If not provided, a default lighter version of the main color will be used.
  final Color? trackColor;
}

final class _GradientProgressColor extends SaProgressColor {
  const _GradientProgressColor(this.gradient, {this.trackColor});

  final Gradient gradient;

  /// Optional track color for gradient progress. If not provided, a default light color from the theme will be used.
  final Color? trackColor;
}

/// A customizable linear progress indicator widget.
class SaProgressIndicator extends StatefulWidget {
  /// Creates a [SaProgressIndicator] widget.
  const SaProgressIndicator({
    super.key,
    this.value,
    this.color,
    this.borderRadius,
    this.height = 4,
    this.shouldAnimateValue = false,
    this.animationDuration = const Duration(milliseconds: 300),
    this.animationCurve = Curves.easeInOut,
  });

  /// The current progress value between 0.0 and 1.0.
  ///
  /// If null, the indicator is indeterminate.
  final double? value;

  /// The color of the progress indicator.
  final SaProgressColor? color;

  /// The height of the progress indicator.
  final double height;

  /// The border radius of the progress indicator.
  final double? borderRadius;

  /// Whether to animate value changes smoothly.
  final bool shouldAnimateValue;

  /// The duration of the value change animation.
  final Duration animationDuration;

  /// The curve of the value change animation.
  final Curve animationCurve;

  @override
  State<SaProgressIndicator> createState() => _SaProgressIndicatorState();
}

class _SaProgressIndicatorState extends State<SaProgressIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _valueAnimation;
  double _currentValue = 0;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: widget.animationDuration,
    );

    _currentValue = widget.value ?? 0.0;
    _valueAnimation =
        Tween<double>(
          begin: _currentValue,
          end: _currentValue,
        ).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: widget.animationCurve,
          ),
        );
  }

  @override
  void didUpdateWidget(SaProgressIndicator oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Update animation duration if changed
    if (widget.animationDuration != oldWidget.animationDuration) {
      _animationController.duration = widget.animationDuration;
    }

    // Animate to new value if it changed and smooth animation is enabled
    if (widget.value != oldWidget.value && widget.value != null && widget.shouldAnimateValue) {
      _animateToValue(widget.value!);
    } else if (widget.value != oldWidget.value && widget.value != null) {
      // Without smooth animation, just update the current value
      _currentValue = widget.value!;
    }
  }

  void _animateToValue(double newValue) {
    final currentAnimatedValue = _valueAnimation.value;

    _valueAnimation =
        Tween<double>(
          begin: currentAnimatedValue,
          end: newValue,
        ).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: widget.animationCurve,
          ),
        );

    _animationController.reset();
    unawaited(_animationController.forward());

    _currentValue = newValue;
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final resolvedColor = widget.color ?? SaProgressColor.solid(context.colors.primary);

    // If value is null (indeterminate), don't animate
    if (widget.value == null) {
      return _buildIndicator(null, resolvedColor);
    }

    // Without smooth animation, just show the value directly
    if (!widget.shouldAnimateValue) {
      return _buildIndicator(widget.value, resolvedColor);
    }

    // With smooth animation, use AnimatedBuilder for optimal rebuilds
    return AnimatedBuilder(
      animation: _valueAnimation,
      builder: (context, child) {
        return _buildIndicator(_valueAnimation.value, resolvedColor);
      },
    );
  }

  Widget _buildIndicator(double? value, SaProgressColor resolvedColor) {
    return switch (resolvedColor) {
      // For solid color, we can directly use LinearProgressIndicator with valueColor
      _SolidProgressColor(:final color, :final trackColor) => LinearProgressIndicator(
        value: value,
        valueColor: AlwaysStoppedAnimation(color),
        minHeight: widget.height,
        backgroundColor: trackColor ?? color.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(widget.borderRadius ?? AppRadius.xs),
      ),
      // For gradient, we use a custom implementation since LinearProgressIndicator doesn't support gradients directly
      _GradientProgressColor(:final gradient, :final trackColor) => _GradientProgressBar(
        value: value ?? 0.0,
        height: widget.height,
        gradient: gradient,
        trackColor: trackColor,
        borderRadius: widget.borderRadius ?? AppRadius.xs,
      ),
    };
  }
}

class _GradientProgressBar extends StatelessWidget {
  const _GradientProgressBar({
    required this.value,
    required this.gradient,
    required this.trackColor,
    required this.borderRadius,
    this.height = 4,
  });

  final double value;
  final double height;
  final Gradient gradient;
  final Color? trackColor;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    final bg = context.colors.surfaceContainerHighest;

    return SizedBox(
      height: height,
      child: CustomPaint(
        painter: _GradientProgressPainter(
          value: value.clamp(0.0, 1.0),
          gradient: gradient,
          backgroundColor: trackColor ?? bg,
          borderRadius: borderRadius,
        ),
      ),
    );
  }
}

class _GradientProgressPainter extends CustomPainter {
  const _GradientProgressPainter({
    required this.value,
    required this.gradient,
    required this.backgroundColor,
    required this.borderRadius,
  });

  final double value;
  final Gradient gradient;
  final Color backgroundColor;
  final double borderRadius;

  @override
  void paint(Canvas canvas, Size size) {
    final radius = Radius.circular(borderRadius);
    final trackRect = Offset.zero & size;
    final rrect = RRect.fromRectAndRadius(trackRect, radius);

    canvas.drawRRect(rrect, Paint()..color = backgroundColor);

    if (value <= 0) return;

    final gradientPaint = Paint()..shader = gradient.createShader(trackRect);
    final progressRect = Rect.fromLTWH(0, 0, size.width * value, size.height);
    final progressRRect = RRect.fromRectAndRadius(progressRect, radius);

    canvas
      ..save()
      ..clipRRect(progressRRect)
      ..drawRect(trackRect, gradientPaint)
      ..restore();
  }

  @override
  bool shouldRepaint(_GradientProgressPainter oldDelegate) =>
      oldDelegate.value != value ||
      oldDelegate.gradient != gradient ||
      oldDelegate.backgroundColor != backgroundColor ||
      oldDelegate.borderRadius != borderRadius;
}
