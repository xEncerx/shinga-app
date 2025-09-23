import 'package:flutter/material.dart';

import '../core.dart';

/// A widget that displays a statistic item with an icon, value, and label.
class StatisticItem extends StatelessWidget {
  /// Creates a [StatisticItem].
  ///
  /// - `icon` - The icon to display.
  /// - `value` - The value to display.
  /// - `label` - The description of the statistic item.
  /// - `color` - The color of the icon and border. If not provided, the primary color of the theme is used.
  const StatisticItem({
    super.key,
    required this.icon,
    required this.value,
    required this.label,
    this.color,
  });

  final IconData icon;
  final String value;
  final String label;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = this.color ?? theme.colorScheme.primary;

    return Column(
      children: [
        IconContainer(
          icon: icon,
          color: color,
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: theme.textTheme.titleSmall.semiBold,
        ),
        Text(
          label,
          maxLines: 1,
          style: theme.textTheme.bodySmall.withColor(theme.hintColor).ellipsis,
        ),
      ],
    );
  }
}
