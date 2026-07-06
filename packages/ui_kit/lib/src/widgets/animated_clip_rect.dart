import 'dart:async';

import 'package:flutter/material.dart';

/// A widget that animates the clipping of its child based on the [open] state.
class SaAnimatedClipRect extends StatefulWidget {
  /// Creates a widget that animates the clipping of its child.
  const SaAnimatedClipRect({
    required this.open,
    required this.child,
    this.duration = const Duration(milliseconds: 300),
    this.curve = Curves.easeInOut,
    this.alignment = Alignment.center,
    super.key,
  });

  /// Whether the clip rect is open (expanded) or closed (collapsed).
  final bool open;

  /// The duration of the animation.
  final Duration duration;

  /// The curve of the animation.
  final Curve curve;

  /// The alignment for the clip rect animation.
  final Alignment alignment;

  /// The child widget to be clipped.
  final Widget child;

  @override
  State<SaAnimatedClipRect> createState() => _SaAnimatedClipRectState();
}

class _SaAnimatedClipRectState extends State<SaAnimatedClipRect>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      value: widget.open ? 1.0 : 0.0,
      vsync: this,
    );
    _animation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: widget.curve,
        reverseCurve: widget.curve,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(SaAnimatedClipRect oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.open != widget.open) {
      unawaited(_toggle());
    }
  }

  Future<void> _toggle() async {
    if (widget.open) {
      await _controller.forward();
    } else {
      await _controller.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    final animateHorizontally = widget.alignment.x != 0.0;
    final animateVertically = widget.alignment.y != 0.0;

    final bothDirections = widget.alignment == Alignment.center;

    return ClipRect(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (_, child) {
          return Align(
            alignment: widget.alignment,
            heightFactor: (animateVertically || bothDirections) ? _animation.value : 1.0,
            widthFactor: (animateHorizontally || bothDirections) ? _animation.value : 1.0,
            child: child,
          );
        },
        child: widget.child,
      ),
    );
  }
}
