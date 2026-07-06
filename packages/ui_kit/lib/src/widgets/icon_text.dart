import 'package:flutter/material.dart';
import 'package:ui_kit/ui_kit.dart';

/// Alignment options for the icon within [SaIconText].
enum SaIconAlignment {
  /// Align the icon to the start.
  start,

  /// Align the icon to the end.
  end,

  /// Align the icon to the top.
  top,

  /// Align the icon to the bottom.
  bottom,
}

/// A row-based content layout that combines an [icon] and a [label].
///
/// Arranges the icon and label horizontally, with [iconAlignment] controlling
/// whether the icon appears before or after the label.
class SaIconText extends StatelessWidget {
  /// Creates a [SaIconText] widget.
  const SaIconText({
    required this.label,
    required this.icon,
    this.iconAlignment = SaIconAlignment.start,
    this.spacing,
    super.key,
  });

  /// The text or widget displayed as the label.
  final Widget label;

  /// The icon displayed alongside the [label].
  final Widget icon;

  /// Determines whether the [icon] appears before or after the [label].
  ///
  /// Defaults to [SaIconAlignment.start].
  final SaIconAlignment iconAlignment;

  /// The spacing between the [icon] and [label].
  ///
  /// Defaults to [AppSpacing.s] when not provided.
  final double? spacing;

  @override
  Widget build(BuildContext context) {
    final effectiveSpacing = spacing ?? AppSpacing.s;

    return iconAlignment == SaIconAlignment.top || iconAlignment == SaIconAlignment.bottom
        ? Column(
            mainAxisSize: MainAxisSize.min,
            children: iconAlignment == SaIconAlignment.top
                ? [icon, Flexible(child: label)]
                : [Flexible(child: label), icon],
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            spacing: effectiveSpacing,
            children: iconAlignment == SaIconAlignment.start
                ? <Widget>[icon, Flexible(child: label)]
                : <Widget>[Flexible(child: label), icon],
          );
  }
}
