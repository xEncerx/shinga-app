import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ui_kit/ui_kit.dart';

/// A widget that displays text alongside a copy icon.
///
/// Tapping the widget copies the [textToCopy] to the clipboard and calls the
/// optional [onCopied] callback.
class SaCopyText extends StatelessWidget {
  /// Creates a [SaCopyText] widget with a custom label widget and specific copy text.
  ///
  /// Useful when the displayed widget is different from the text to be copied
  /// (e.g. displaying "ID: 1192" but copying "1192").
  const SaCopyText({
    required Widget label,
    required this.textToCopy,
    this.icon,
    this.iconAlignment = SaIconAlignment.end,
    this.spacing,
    this.onCopied,
    super.key,
  }) : _label = label;

  /// Creates a [SaCopyText] widget where the displayed text and copied text are identical.
  ///
  /// This infers the [textToCopy] directly from the [text] widget's data.
  SaCopyText.text(
    SaText text, {
    this.icon,
    this.iconAlignment = SaIconAlignment.start,
    this.spacing,
    this.onCopied,
    super.key,
  }) : _label = text,
       textToCopy = text.data;

  /// The widget to display next to the copy icon.
  final Widget _label;

  /// The text that will be copied to the clipboard when tapped.
  final String textToCopy;

  /// An optional icon to display alongside the text.
  ///
  /// If not provided, a default copy icon will be used.
  final Widget? icon;

  /// Determines whether the icon appears before or after the text.
  final SaIconAlignment iconAlignment;

  /// The spacing between the icon and text.
  final double? spacing;

  /// An optional callback invoked after the text is successfully copied.
  final ValueChanged<String>? onCopied;

  Future<void> _handleCopy() async {
    await Clipboard.setData(ClipboardData(text: textToCopy));
    onCopied?.call(textToCopy);
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: _handleCopy,
        child: SaIconText(
          label: _label,
          icon: icon ?? const SaIcon(icon: SaIconSource.huge(HugeIconsStrokeRounded.copy01)),
          iconAlignment: iconAlignment,
          spacing: spacing,
        ),
      ),
    );
  }
}
