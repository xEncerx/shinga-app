import 'package:flutter/material.dart';

/// A flexible divider widget that can be oriented horizontally or vertically.
class SaDivider extends StatelessWidget {
  /// Creates a horizontal [SaDivider] widget.
  const SaDivider({
    super.key,
    this.height,
    this.thickness,
    this.indent,
    this.endIndent,
    this.color,
    this.borderRadius,
  }) : _isVertical = false;

  /// Creates a vertical [SaDivider] widget.
  const SaDivider.vertical({
    super.key,
    this.height,
    this.thickness,
    this.indent,
    this.endIndent,
    this.color,
    this.borderRadius,
  }) : _isVertical = true;

  /// The total height or width of the divider depending on orientation.
  final double? height;

  /// The thickness of the divider line.
  final double? thickness;

  /// The amount of empty space at the start of the divider.
  final double? indent;

  /// The amount of empty space at the end of the divider.
  final double? endIndent;

  /// The color of the divider line.
  final Color? color;

  /// The border radius applied to the divider line.
  final double? borderRadius;

  /// Whether this divider is vertical or horizontal
  final bool _isVertical;

  @override
  Widget build(BuildContext context) {
    if (_isVertical) {
      return VerticalDivider(
        width: height,
        thickness: thickness,
        indent: indent,
        endIndent: endIndent,
        color: color,
        radius: borderRadius != null ? BorderRadius.circular(borderRadius!) : null,
      );
    }
    return Divider(
      height: height,
      thickness: thickness,
      indent: indent,
      endIndent: endIndent,
      color: color,
      radius: borderRadius != null ? BorderRadius.circular(borderRadius!) : null,
    );
  }
}
