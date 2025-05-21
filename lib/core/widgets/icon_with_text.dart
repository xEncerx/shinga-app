import 'package:flutter/material.dart';

class IconWithText extends StatelessWidget {
  const IconWithText({
    super.key,
    required this.text,
    required this.icon,
    this.iconSize = 28,
    this.iconColor,
    this.textStyle,
    this.textColor,
    this.spacing = 5,
  });

  final String text;
  final IconData icon;
  final double iconSize;
  final TextStyle? textStyle;
  final double spacing;
  final Color? iconColor;
  final Color? textColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      mainAxisSize: MainAxisSize.min,
      spacing: spacing,
      children: [
        Icon(
          icon,
          size: iconSize,
          color: iconColor ?? theme.hintColor,
        ),
        Flexible(
          child: Text(
            text,
            overflow: TextOverflow.ellipsis,
            style: textStyle ??
                theme.textTheme.bodyLarge?.copyWith(
                  color: textColor ?? theme.hintColor,
                ),
          ),
        ),
      ],
    );
  }
}
