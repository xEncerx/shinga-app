import 'package:flutter/material.dart';

class IconWithText extends StatelessWidget {
  const IconWithText({
    super.key,
    required this.text,
    required this.icon,
    this.iconSize = 28,
    this.iconColor,
    this.isBoldIcon = false,
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
  final bool isBoldIcon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      mainAxisSize: MainAxisSize.min,
      spacing: spacing,
      children: [
        Text(
          String.fromCharCode(icon.codePoint),
          style: TextStyle(
            inherit: false,
            color: iconColor ?? theme.hintColor,
            fontSize: iconSize,
            fontWeight: isBoldIcon ? FontWeight.w600 : FontWeight.w500,
            fontFamily: icon.fontFamily,
            package: icon.fontPackage,
          ),
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
