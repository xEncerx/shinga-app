import 'package:flutter/material.dart';

import '../../i18n/strings.g.dart';
import '../extensions/extensions.dart';

enum ThemeColorType {
  primary,
  secondary,
  error,
  success,
  warning,
  surface,
}

/// A widget to show information messages with customizable styles.
class ShowInfoWidget extends StatelessWidget {
  /// Default constructor
  const ShowInfoWidget({
    super.key,
    required this.title,
    this.description,
    this.onRetry,
    this.icon,
    this.retryText,
    this.themeColorType = ThemeColorType.primary,
  });

  /// Error constructor
  const ShowInfoWidget.error({
    super.key,
    required this.title,
    this.description,
    this.onRetry,
    this.retryText,
  }) : icon = Icons.error_outline_rounded,
       themeColorType = ThemeColorType.error;

  /// Success constructor
  const ShowInfoWidget.success({
    super.key,
    required this.title,
    this.description,
  }) : icon = Icons.check_circle_outline_rounded,
       themeColorType = ThemeColorType.success,
       onRetry = null,
       retryText = null;

  /// Warning constructor
  const ShowInfoWidget.warning({
    super.key,
    required this.title,
    this.description,
    this.onRetry,
    this.retryText,
  }) : icon = Icons.warning_amber_rounded,
       themeColorType = ThemeColorType.warning;

  /// Info constructor
  const ShowInfoWidget.info({
    super.key,
    required this.title,
    this.description,
  }) : icon = Icons.info_outline_rounded,
       themeColorType = ThemeColorType.primary,
       onRetry = null,
       retryText = null;

  /// The title of the info widget.
  final String title;

  /// Optional description text.
  final String? description;

  /// Optional callback for retry action.
  final VoidCallback? onRetry;

  /// Optional icon to display.
  final IconData? icon;

  /// Optional text for the retry button.
  final String? retryText;

  /// The theme color type to determine the color scheme.
  final ThemeColorType themeColorType;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final t = Translations.of(context);
    final effectiveAccentColor = _getEffectiveColor(themeColorType, theme);

    return Center(
      child: Container(
        padding: const EdgeInsets.all(24),
        margin: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: effectiveAccentColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: effectiveAccentColor.withOpacity(0.2),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: effectiveAccentColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  size: 48,
                  color: effectiveAccentColor,
                ),
              ),
            const SizedBox(height: 16),
            Text(
              title,
              style: theme.textTheme.headlineSmall.withColor(effectiveAccentColor).semiBold,
              textAlign: TextAlign.center,
            ),
            if (description != null) ...[
              const SizedBox(height: 8),
              Text(
                description!,
                style: theme.textTheme.bodyMedium
                    .withColor(theme.colorScheme.onSurface.withOpacity(0.7))
                    .height(1.4),
                textAlign: TextAlign.center,
              ),
            ],
            if (onRetry != null) ...[
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: onRetry,
                  style: FilledButton.styleFrom(
                    backgroundColor: effectiveAccentColor.withOpacity(0.1),
                    foregroundColor: effectiveAccentColor,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.refresh_rounded,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        retryText ?? t.common.retry,
                        style: theme.textTheme.labelLarge.semiBold,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Color _getEffectiveColor(ThemeColorType themeColor, ThemeData themeData) {
    switch (themeColor) {
      case ThemeColorType.primary:
        return themeData.colorScheme.primary;
      case ThemeColorType.secondary:
        return themeData.colorScheme.secondary;
      case ThemeColorType.error:
        return themeData.colorScheme.error;
      case ThemeColorType.success:
        return Colors.green;
      case ThemeColorType.warning:
        return Colors.orange;
      case ThemeColorType.surface:
        return themeData.colorScheme.surface;
    }
  }
}
