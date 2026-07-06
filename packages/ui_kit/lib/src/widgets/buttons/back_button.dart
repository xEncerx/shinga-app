import 'package:flutter/material.dart';
import 'package:ui_kit/src/src.dart';

/// A custom back button widget for the UI kit.
class SaBackButton extends StatelessWidget {
  /// Creates a [SaBackButton] instance.
  const SaBackButton({
    this.icon,
    this.onPressed,
    super.key,
  });

  /// The icon to display inside the back button.
  final SaIconSource? icon;

  /// The callback that is called when the button is tapped.
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return UnconstrainedBox(
      child: SaIconButton(
        icon: SaIcon(
          icon: icon ?? const SaIconSource.material(Icons.arrow_back_ios_new_rounded),
          size: 18,
        ),
        onPressed: onPressed ?? () => Navigator.of(context).pop(),
      ),
    );
  }
}
