import 'package:flutter/material.dart';
import 'package:ui_kit/ui_kit.dart';

/// A box widget that displays statistical information with an optional icon and description.
class SaStatisticBox extends StatelessWidget {
  /// Creates a [SaStatisticBox] widget.
  const SaStatisticBox({
    required this.value,
    super.key,
    this.icon,
    this.description,
    this.iconAlignment = SaIconAlignment.top,
    this.showBorder = true,
    this.borderRadius,
    this.backgroundColor,
    this.iconColor,
    this.crossAxisAlignment = CrossAxisAlignment.center,
  });

  /// The optional icon displayed at the top of the box.
  final SaIconSource? icon;

  /// The main value text to display prominently.
  final String value;

  /// Optional descriptive text shown below the icon but above the value.
  final String? description;

  /// The background color of the container.
  final Color? backgroundColor;

  /// The color of the icon.
  final Color? iconColor;

  /// The alignment of the icon relative to the text.
  final SaIconAlignment iconAlignment;

  /// Whether to show a border around the container.
  final bool showBorder;

  /// The border radius of the container.
  final double? borderRadius;

  /// The alignment of the text within the column.
  final CrossAxisAlignment crossAxisAlignment;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.s),
      constraints: const BoxConstraints(
        minWidth: 80,
        minHeight: 40,
      ),
      decoration: BoxDecoration(
        color: backgroundColor ?? Colors.transparent,
        border: showBorder
            ? Border.all(
                color: colors.outline.withValues(alpha: 0.3),
                width: 1.2,
              )
            : null,
        borderRadius: BorderRadius.circular(borderRadius ?? AppRadius.l),
      ),
      child: SaIconText(
        iconAlignment: iconAlignment,
        label: Column(
          crossAxisAlignment: crossAxisAlignment,
          children: [
            if (description != null)
              SaText(
                description!,
                style: AppTextStyle.captionL.copyWith(
                  color: Theme.of(context).hintColor,
                ),
              ),
            SaText(
              value,
              style: AppTextStyle.titleS,
            ),
          ],
        ),
        icon: icon != null
            ? SaIcon(
                icon: icon!,
                size: 22,
                color: iconColor,
              )
            : const SizedBox.shrink(),
      ),
    );
  }
}
