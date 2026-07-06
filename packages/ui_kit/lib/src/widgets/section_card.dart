import 'package:flutter/material.dart';
import 'package:ui_kit/ui_kit.dart';

/// A card widget with a header section and content.
class SaSectionCard extends StatelessWidget {
  /// Creates a [SaSectionCard] widget.
  const SaSectionCard({
    required this.headerLabel,
    required this.child,
    super.key,
    this.elevation = 2,
    this.contentPadding,
    this.backgroundColor,
    this.headerIcon,
  });

  /// Creates a transparent [SaSectionCard] widget.
  const SaSectionCard.transparent({
    required this.headerLabel,
    required this.child,
    super.key,
    this.headerIcon,
  }) : backgroundColor = Colors.transparent,
       contentPadding = EdgeInsets.zero,
       elevation = 0;

  /// The label widget for the header.
  final Widget headerLabel;

  /// The optional icon widget for the header.
  final Widget? headerIcon;

  /// The padding around the content. If null, default padding is applied.
  final EdgeInsetsGeometry? contentPadding;

  /// The elevation of the card.
  final double elevation;

  /// The background color of the card. If null, the default card color is used.
  final Color? backgroundColor;

  /// The content widget displayed below the header.
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colors;

    final effectiveBackgroundColor = backgroundColor ?? colorScheme.surfaceContainerLow;

    return Material(
      color: effectiveBackgroundColor,
      elevation: elevation,
      borderRadius: BorderRadius.circular(AppRadius.card),
      child: Padding(
        padding: contentPadding ?? const EdgeInsets.all(AppSpacing.s),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          spacing: AppSpacing.s,
          children: [
            SaIconText(
              label: DefaultTextStyle(
                style: AppTextStyle.titleM.copyWith(
                  color: colorScheme.onSurface,
                ),
                child: headerLabel,
              ),
              icon: IconTheme(
                data: IconThemeData(
                  color: colorScheme.onSurface,
                ),
                child: headerIcon ?? const SizedBox.shrink(),
              ),
            ),
            Flexible(child: child),
          ],
        ),
      ),
    );
  }
}
