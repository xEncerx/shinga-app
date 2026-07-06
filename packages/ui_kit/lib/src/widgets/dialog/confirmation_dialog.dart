import 'package:flutter/material.dart';
import 'package:ui_kit/ui_kit.dart';

/// A confirmation dialog with cancel and confirm buttons.
///
/// The [onConfirm] callback is executed only when the confirm button is pressed.
class SaConfirmationDialog extends StatelessWidget {
  /// Creates a [SaConfirmationDialog] widget.
  const SaConfirmationDialog({
    required this.onConfirm,
    super.key,
    this.icon,
    this.iconColor,
    this.title,
    this.titleTextStyle,
    this.description,
    this.descriptionTextStyle,
    this.cancelText,
    this.confirmText,
    this.cancelButton,
    this.confirmButton,
    this.backgroundColor,
    this.elevation,
    this.shape,
    this.insetPadding,
  });

  /// The icon displayed at the top of the dialog.
  final SaIconSource? icon;

  /// Color applied to the [icon].
  final Color? iconColor;

  /// The title text of the dialog.
  final String? title;

  /// Style for the title text.
  final TextStyle? titleTextStyle;

  /// The description text of the dialog.
  final String? description;

  /// Style for the description text.
  final TextStyle? descriptionTextStyle;

  /// Text for the cancel button.
  final String? cancelText;

  /// Text for the confirm button.
  final String? confirmText;

  /// Custom cancel button widget.
  final Widget? cancelButton;

  /// Custom confirm button widget.
  final Widget? confirmButton;

  /// Called when the confirm button is pressed.
  final VoidCallback onConfirm;

  /// Background color of the dialog.
  final Color? backgroundColor;

  /// Elevation of the dialog.
  final double? elevation;

  /// Shape of the dialog border.
  final ShapeBorder? shape;

  /// Padding around the dialog when displayed.
  final EdgeInsets? insetPadding;

  void _onCancel(BuildContext context) {
    Navigator.of(context).pop(false);
  }

  void _onConfirm(BuildContext context) {
    Navigator.of(context).pop(true);
    onConfirm.call();
  }

  @override
  Widget build(BuildContext context) {
    return SaAppDialog(
      icon: icon ?? const SaIconSource.huge(HugeIconsStrokeRounded.alert02),
      iconColor: iconColor ?? context.appColors.warning,
      title: title != null ? SaText(title!) : null,
      titleTextStyle: titleTextStyle,
      content: description != null ? SaText(description!) : const SizedBox.shrink(),
      contentTextStyle: descriptionTextStyle,
      actions: [
        cancelButton ??
            SaTextButton(
              onPressed: () => _onCancel(context),
              child: SaText(cancelText ?? 'Cancel'),
            ),
        confirmButton ??
            SaPrimaryButton(
              width: 120,
              onPressed: () => _onConfirm(context),
              child: SaText(confirmText ?? 'Yes'),
            ),
      ],
      backgroundColor: backgroundColor,
      elevation: elevation,
      shape: shape,
      insetPadding: insetPadding,
    );
  }
}
