import 'package:flutter/material.dart';

import '../core.dart';

/// A widget that displays an icon alongside text in a row.
///
/// This widget provides a simple way to create a horizontal layout with
/// an icon followed by text, with customizable styling options for both.
class IconWithText extends StatelessWidget {
  /// Creates an icon with text widget.
  /// - `text` - The text to display.
  /// - `icon` - The icon to display.
  /// - `maxLines` - Maximum number of lines for the text.
  /// - `textStyle` - Style for the text.
  /// - `textColor` - Color of the text.
  /// - `spacing` - Space between icon and text.
  const IconWithText({
    super.key,
    required this.text,
    required this.icon,
    this.maxLines = 1,
    this.textStyle,
    this.textColor,
    this.spacing = 5,
  });

  final String text;
  final int maxLines;
  final Widget icon;
  final TextStyle? textStyle;
  final double spacing;
  final Color? textColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      mainAxisSize: MainAxisSize.min,
      spacing: spacing,
      children: [
        icon,
        Flexible(
          child: Text(
            text,
            maxLines: maxLines,
            style:
                textStyle ??
                theme.textTheme.bodyLarge
                    .withColor(
                      textColor ?? theme.colorScheme.onSurface,
                    )
                    .ellipsis,
          ),
        ),
      ],
    );
  }
}
