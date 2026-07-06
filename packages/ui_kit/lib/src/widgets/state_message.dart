import 'package:flutter/material.dart';
import 'package:ui_kit/src/src.dart';

/// An enumeration of different state message types used in [SaStateMessage].
enum SaStateMessageType {
  /// Informational state message, typically used for neutral messages.
  info,

  /// Error state message, typically used for error or failure messages.
  error,

  /// Success state message, typically used for success or completion messages.
  success,

  /// Warning state message, typically used for cautionary messages.
  warning,

  /// Empty state message, typically used for empty or no data messages.
  empty,
}

/// A widget that displays a state message.
class SaStateMessage extends StatelessWidget {
  /// Creates a [SaStateMessage] widget.
  const SaStateMessage({
    required this.title,
    this.description,
    this.icon,
    this.spacing,
    this.buttonText,
    this.onPressed,
    this.stateType = SaStateMessageType.empty,
    super.key,
  });

  /// Creates an empty state message.
  const SaStateMessage.empty({
    required this.title,
    this.description,
    this.spacing,
    super.key,
  }) : stateType = SaStateMessageType.empty,
       icon = null,
       buttonText = null,
       onPressed = null;

  /// Creates a warning state message.
  const SaStateMessage.warning({
    required this.title,
    this.description,
    this.spacing,
    this.buttonText,
    this.onPressed,
    super.key,
  }) : stateType = SaStateMessageType.warning,
       icon = const SaIconSource.material(Icons.warning_rounded);

  /// Creates an error state message.
  const SaStateMessage.error({
    required this.title,
    this.description,
    this.spacing,
    this.buttonText,
    this.onPressed,
    super.key,
  }) : stateType = SaStateMessageType.error,
       icon = const SaIconSource.material(Icons.error_rounded);

  /// Creates a success state message.
  const SaStateMessage.success({
    required this.title,
    this.description,
    this.spacing,
    super.key,
  }) : stateType = SaStateMessageType.success,
       icon = const SaIconSource.material(Icons.check_circle_outline_rounded),
       buttonText = null,
       onPressed = null;

  /// Creates an info state message.
  const SaStateMessage.info({
    required this.title,
    this.description,
    this.spacing,
    super.key,
  }) : stateType = SaStateMessageType.info,
       icon = const SaIconSource.material(Icons.info_outline_rounded),
       buttonText = null,
       onPressed = null;

  /// The title text of the state message.
  final String title;

  /// The optional description text.
  final String? description;

  /// The optional icon to display.
  final SaIconSource? icon;

  /// The spacing between elements.
  final double? spacing;

  /// The optional button text.
  final String? buttonText;

  /// The optional button press callback.
  final VoidCallback? onPressed;

  /// The type of state message.
  final SaStateMessageType stateType;

  /// Builds the widget tree for this state message.
  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colors;
    final (fg, bg) = _getColors(context);

    return ConstrainedBox(
      constraints: const BoxConstraints(
        maxHeight: 400,
        maxWidth: 400,
      ),
      child: Center(
        child: Column(
          spacing: spacing ?? AppSpacing.s,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) _buildStateIcon(fg, bg),
            const SizedBox(height: AppSpacing.s),
            SaText(
              title,
              textAlign: TextAlign.center,
              style: AppTextStyle.h5,
            ),
            if (description != null)
              SaText(
                description!,
                textAlign: TextAlign.center,
                style: AppTextStyle.titleM.copyWith(color: colorScheme.onSurfaceVariant),
              ),
            const SizedBox(height: AppSpacing.s),
            if (buttonText != null)
              SaPrimaryButton(
                width: 140,
                height: 38,
                foregroundColor: fg,
                backgroundColor: bg,
                borderRadius: BorderRadius.circular(AppRadius.full),
                onPressed: onPressed,
                child: SaText(
                  buttonText!,
                  style: AppTextStyle.bodyBold,
                ),
              ),
          ],
        ),
      ),
    );
  }

  (Color fg, Color bg) _getColors(BuildContext context) {
    final colorScheme = context.colors;
    final appColors = context.appColors;

    switch (stateType) {
      case SaStateMessageType.info:
        return (colorScheme.onPrimary, colorScheme.primary);
      case SaStateMessageType.error:
        return (colorScheme.onErrorContainer, colorScheme.errorContainer);
      case SaStateMessageType.success:
        return (appColors.onSuccess, appColors.success);
      case SaStateMessageType.warning:
        return (appColors.onWarning, appColors.warning);
      case SaStateMessageType.empty:
        return (colorScheme.onSurfaceVariant, colorScheme.surfaceContainerHighest);
    }
  }

  Widget _buildStateIcon(Color iconColor, Color backgroundColor) {
    return SaDecoratedIcon(
      icon: icon!,
      iconSize: 48,
      shape: BoxShape.circle,
      iconColor: iconColor,
      backgroundColor: backgroundColor,
    );
  }
}
