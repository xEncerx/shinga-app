import 'package:flutter/material.dart';
import 'package:ui_kit/ui_kit.dart';

/// A dialog with a text field, cancel, and confirm buttons.
///
/// The [onConfirm] callback is executed when the confirm button is pressed,
/// providing the current text from the text field.
class SaTextFieldDialog extends StatefulWidget {
  /// Creates a [SaTextFieldDialog] widget.
  const SaTextFieldDialog({
    required this.onConfirm,
    required this.textFieldBuilder,
    super.key,
    this.initialText,
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

  /// Builder for the text field to display inside the dialog.
  ///
  /// Provides a [TextEditingController] that is managed by the dialog.
  final Widget Function(BuildContext context, TextEditingController controller) textFieldBuilder;

  /// Initial text to populate the text field.
  final String? initialText;

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

  /// Called when the confirm button is pressed, yielding the text field's value.
  final ValueChanged<String> onConfirm;

  /// Background color of the dialog.
  final Color? backgroundColor;

  /// Elevation of the dialog.
  final double? elevation;

  /// Shape of the dialog border.
  final ShapeBorder? shape;

  /// Padding around the dialog when displayed.
  final EdgeInsets? insetPadding;

  @override
  State<SaTextFieldDialog> createState() => _SaTextFieldDialogState();
}

class _SaTextFieldDialogState extends State<SaTextFieldDialog> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialText);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onCancel() => Navigator.of(context).pop(false);

  void _onConfirm() {
    Navigator.of(context).pop(true);
    widget.onConfirm(_controller.text);
  }

  @override
  Widget build(BuildContext context) {
    return SaAppDialog(
      icon: widget.icon,
      iconColor: widget.iconColor ?? context.colors.primary,
      title: widget.title != null ? SaText(widget.title!) : null,
      titleTextStyle: widget.titleTextStyle,
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (widget.description != null) ...[
              SaText(widget.description!),
              const SizedBox(height: AppSpacing.m),
            ],
            widget.textFieldBuilder(context, _controller),
          ],
        ),
      ),
      contentTextStyle: widget.descriptionTextStyle,
      actions: [
        widget.cancelButton ??
            SaTextButton(
              onPressed: _onCancel,
              child: SaText(widget.cancelText ?? 'Cancel'),
            ),
        widget.confirmButton ??
            SaPrimaryButton(
              width: 120,
              onPressed: _onConfirm,
              child: SaText(widget.confirmText ?? 'Confirm'),
            ),
      ],
      backgroundColor: widget.backgroundColor,
      elevation: widget.elevation,
      shape: widget.shape,
      insetPadding: widget.insetPadding,
    );
  }
}
