import 'package:flutter/material.dart';

class AuthNavigationButton extends StatelessWidget {
  const AuthNavigationButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.verticalPadding = 13,
    this.horizontalPadding = 20,
  });

  final String text;
  final VoidCallback onPressed;
  final double horizontalPadding;
  final double verticalPadding;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return FilledButton.tonal(
      onPressed: () => onPressed.call(),
      style: FilledButton.styleFrom(
        elevation: 3,
        padding: EdgeInsets.symmetric(
          vertical: verticalPadding,
          horizontal: horizontalPadding,
        ),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topRight: Radius.circular(25),
            bottomRight: Radius.circular(25),
          ),
        ),
      ),
      child: Text(
        text,
        style: theme.textTheme.bodyLarge,
      ),
    );
  }
}
