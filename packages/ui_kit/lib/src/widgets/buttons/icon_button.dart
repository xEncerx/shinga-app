import 'package:flutter/material.dart';
import 'package:ui_kit/ui_kit.dart';

/// A styled icon button that wraps Flutter's [IconButton] with app-specific defaults.
class SaIconButton extends StatelessWidget {
  /// Creates a [SaIconButton] widget.
  const SaIconButton({
    required this.icon,
    super.key,
    this.onPressed,
    this.onLongPress,
    this.visualDensity,
    this.padding,
    this.alignment,
    this.splashRadius,
    this.focusNode,
    this.autofocus = false,
    this.tooltip,
    this.enableFeedback,
    this.constraints,
    this.style,
    this.isSelected,
  });

  /// The icon to display inside the button.
  final SaIcon icon;

  /// The callback when button is pressed.
  final VoidCallback? onPressed;

  /// The callback when button is long-pressed.
  final VoidCallback? onLongPress;

  /// Defines how compact the button's layout will be.
  ///
  /// See [VisualDensity] for more details.
  final VisualDensity? visualDensity;

  /// The padding around the button's icon.
  final EdgeInsetsGeometry? padding;

  /// Defines how the icon is positioned within the button.
  ///
  /// Defaults to [Alignment.center].
  final AlignmentGeometry? alignment;

  /// The splash radius of the button's [InkWell].
  ///
  /// If null, the default splash radius is used.
  final double? splashRadius;

  /// An optional focus node to control focus behavior.
  final FocusNode? focusNode;

  /// Whether the button should be focused automatically.
  ///
  /// Defaults to `false`.
  final bool autofocus;

  /// The text displayed when the user hovers over or long-presses the button.
  final String? tooltip;

  /// Whether detected gestures should provide acoustic and/or haptic feedback.
  ///
  /// Defaults to the value from the parent [IconTheme].
  final bool? enableFeedback;

  /// Optional size constraints for the button.
  ///
  /// When not null, overrides the default minimum and maximum size constraints.
  final BoxConstraints? constraints;

  /// Customizes the button's appearance using [ButtonStyle].
  final ButtonStyle? style;

  /// Whether the button is in a selected state.
  ///
  /// Used together with [ButtonStyle.iconColor] and [ButtonStyle.foregroundColor]
  /// to apply different colors when selected.
  final bool? isSelected;

  bool get _isEnabled => onPressed != null || onLongPress != null;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onPressed,
      onLongPress: onLongPress,
      icon: icon,
      mouseCursor: _isEnabled ? SystemMouseCursors.click : SystemMouseCursors.basic,
      visualDensity: visualDensity,
      padding: padding,
      alignment: alignment,
      splashRadius: splashRadius,
      focusNode: focusNode,
      autofocus: autofocus,
      tooltip: tooltip,
      enableFeedback: enableFeedback,
      constraints: constraints,
      style: style,
      isSelected: isSelected,
    );
  }
}
