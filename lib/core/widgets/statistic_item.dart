import 'package:flutter/material.dart';

import '../core.dart';

/// A widget that displays a statistic item with an icon, value, and label.
class StatisticItem extends StatelessWidget {
  /// Creates a [StatisticItem].
  /// 
  /// - `icon` - The icon to display.
  /// - `value` - The value to display.
  /// - `label` - The description of the statistic item.
  const StatisticItem({
    super.key,
    required this.icon,
    required this.value,
    required this.label,
  });

  final IconData icon;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SizedBox(
      width: 80,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: theme.colorScheme.primary),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: theme.textTheme.bodyMedium,
          ),
          Text(
            label,
            maxLines: 1,
            style: theme.textTheme.bodySmall.withColor(theme.hintColor).ellipsis,
          ),
        ],
      ),
    );
  }
}
