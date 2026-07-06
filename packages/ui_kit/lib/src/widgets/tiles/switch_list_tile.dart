import 'package:flutter/material.dart';
import 'package:ui_kit/ui_kit.dart';

/// A [SaListTile] with an embedded [Switch].
///
/// The [Switch] is placed at the [trailing] position when
/// [switchAlignment] is [IconAlignment.end] (default), or at the
/// [leading] position when [IconAlignment.start].
class SaSwitchListTile extends StatelessWidget {
  /// Creates a [SaSwitchListTile].
  const SaSwitchListTile({
    required this.value,
    required this.onChanged,
    this.leading,
    this.title,
    this.subtitle,
    this.trailing,
    this.contentPadding,
    this.switchAlignment = IconAlignment.end,
    this.borderRadius,
    this.enabled = true,
    this.constraints,
    this.tileColor,
    this.checkedColor,
    this.uncheckedColor,
    this.onLongPress,
    this.activeColor,
    this.activeTrackColor,
    this.inactiveThumbColor,
    this.inactiveTrackColor,
    this.thumbColor,
    this.trackColor,
    this.trackOutlineColor,
    this.thumbIcon,
    super.key,
  });

  /// Current on/off state of the switch.
  final bool value;

  /// Called when the tile is tapped or the switch is toggled.
  ///
  /// Receives the new boolean value.
  final ValueChanged<bool>? onChanged;

  /// Widget placed at the start of the tile when [switchAlignment] is
  /// [IconAlignment.end], otherwise ignored (the switch occupies that slot).
  final Widget? leading;

  /// Primary content of the tile.
  final Widget? title;

  /// Additional content displayed below [title].
  final Widget? subtitle;

  /// Widget placed at the end of the tile when [switchAlignment] is
  /// [IconAlignment.start], otherwise ignored (the switch occupies that slot).
  final Widget? trailing;

  /// Padding around the tile content.
  ///
  /// Defaults to horizontal [AppSpacing.m].
  final EdgeInsetsGeometry? contentPadding;

  /// Determines whether the [Switch] appears at the start or end of the tile.
  ///
  /// Defaults to [IconAlignment.end].
  final IconAlignment switchAlignment;

  /// Corner radius of the tile.
  ///
  /// Defaults to [AppRadius.card].
  final double? borderRadius;

  /// Whether the tile is interactive.
  final bool enabled;

  /// Constraints applied to the tile.
  final BoxConstraints? constraints;

  /// Background color of the tile.
  final Color? tileColor;

  /// Background color when [value] is `true`.
  ///
  /// Defaults to primary theme color at 20 % opacity.
  final Color? checkedColor;

  /// Background color when [value] is `false`.
  ///
  /// Defaults to secondary theme color at 10 % opacity.
  final Color? uncheckedColor;

  /// Called when the tile is long-pressed.
  final VoidCallback? onLongPress;

  /// The color to use when this switch is on.
  final Color? activeColor;

  /// The color to use on the track when this switch is on.
  final Color? activeTrackColor;

  /// The color to use on the thumb when this switch is off.
  final Color? inactiveThumbColor;

  /// The color to use on the track when this switch is off.
  final Color? inactiveTrackColor;

  /// The color of this [Switch]'s thumb.
  final WidgetStateProperty<Color?>? thumbColor;

  /// The color of this [Switch]'s track.
  final WidgetStateProperty<Color?>? trackColor;

  /// The outline color of this [Switch]'s track.
  final WidgetStateProperty<Color?>? trackOutlineColor;

  /// The icon to use on the thumb of this switch.
  final WidgetStateProperty<Icon?>? thumbIcon;

  Color _resolveTileColor(BuildContext context) {
    if (value) {
      return checkedColor ?? context.colors.primary.withValues(alpha: 0.2);
    }
    return uncheckedColor ?? context.colors.secondary.withValues(alpha: 0.1);
  }

  @override
  Widget build(BuildContext context) {
    final switchWidget = Switch(
      value: value,
      onChanged: enabled ? onChanged : null,
      activeThumbColor: activeColor,
      activeTrackColor: activeTrackColor,
      inactiveThumbColor: inactiveThumbColor,
      inactiveTrackColor: inactiveTrackColor,
      thumbColor: thumbColor,
      trackColor: trackColor,
      trackOutlineColor: trackOutlineColor,
      thumbIcon: thumbIcon,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );

    return SaListTile(
      leading: switchAlignment == IconAlignment.start ? switchWidget : leading,
      title: title,
      subtitle: subtitle,
      trailing: switchAlignment == IconAlignment.end ? switchWidget : trailing,
      contentPadding: contentPadding,
      constraints: constraints,
      borderRadius: borderRadius,
      enabled: enabled,
      tileColor: tileColor ?? _resolveTileColor(context),
      onTap: enabled ? () => onChanged?.call(!value) : null,
      onLongPress: onLongPress,
    );
  }
}
