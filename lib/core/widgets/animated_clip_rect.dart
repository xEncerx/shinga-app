import 'package:flutter/material.dart';

/// A widget that animates the clipping of its child based on the [open] state.
class AnimatedClipRect extends StatefulWidget {
  /// Creates a widget that animates the clipping of its child.
  const AnimatedClipRect({
    super.key,
    required this.open,
    required this.child,
    this.duration = const Duration(milliseconds: 300),
    this.curve = Curves.easeInOut,
    this.alignment = Alignment.center,
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
  State<AnimatedClipRect> createState() => _AnimatedClipRectState();
}

class _AnimatedClipRectState extends State<AnimatedClipRect> with SingleTickerProviderStateMixin {
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
    _animation = Tween(begin: 0.0, end: 1.0).animate(
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
  Widget build(BuildContext context) {
    widget.open ? _controller.forward() : _controller.reverse();

    final bool animateHorizontally = widget.alignment.x != 0.0;
    final bool animateVertically = widget.alignment.y != 0.0;

    final bool bothDirections = widget.alignment == Alignment.center;

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
