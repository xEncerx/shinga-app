import 'package:flutter/material.dart';
import 'package:ui_kit/ui_kit.dart';

/// A [SaListTile] with an embedded [Checkbox].
///
/// The [Checkbox] is placed at the [leading] position when
/// [checkboxAlignment] is [IconAlignment.start] (default), or at the
/// [trailing] position when [IconAlignment.end].
class SaCheckboxListTile extends StatelessWidget {
  /// Creates a [SaCheckboxListTile].
  const SaCheckboxListTile({
    required this.value,
    required this.onChanged,
    this.leading,
    this.title,
    this.subtitle,
    this.trailing,
    this.contentPadding,
    this.checkboxAlignment = IconAlignment.start,
    this.borderRadius,
    this.enabled = true,
    this.constraints,
    this.checkedColor,
    this.uncheckedColor,
    this.onLongPress,
    super.key,
  });

  /// Current checked state of the checkbox.
  final bool value;

  /// Called when the tile is tapped or the checkbox is toggled.
  ///
  /// Receives the new boolean value.
  final ValueChanged<bool?>? onChanged;

  /// Widget placed at the start of the tile when [checkboxAlignment] is
  /// [IconAlignment.end], otherwise ignored (the checkbox occupies that slot).
  final Widget? leading;

  /// Primary content of the tile.
  final Widget? title;

  /// Additional content displayed below [title].
  final Widget? subtitle;

  /// Widget placed at the end of the tile when [checkboxAlignment] is
  /// [IconAlignment.start], otherwise ignored (the checkbox occupies that slot).
  final Widget? trailing;

  /// Padding around the tile content.
  ///
  /// Defaults to horizontal [AppSpacing.m].
  final EdgeInsetsGeometry? contentPadding;

  /// Determines whether the [Checkbox] appears at the start or end of the tile.
  ///
  /// Defaults to [IconAlignment.start].
  final IconAlignment checkboxAlignment;

  /// Corner radius of the tile.
  ///
  /// Defaults to [AppRadius.card].
  final double? borderRadius;

  /// Whether the tile is interactive.
  final bool enabled;

  /// Constraints applied to the tile.
  final BoxConstraints? constraints;

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

  Color _resolveColor(BuildContext context) {
    if (value) {
      return checkedColor ?? context.colors.primary.withValues(alpha: 0.2);
    }
    return uncheckedColor ?? context.colors.secondary.withValues(alpha: 0.1);
  }

  @override
  Widget build(BuildContext context) {
    final checkboxWidget = Checkbox(
      value: value,
      onChanged: enabled ? onChanged : null,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      visualDensity: const VisualDensity(horizontal: -4, vertical: -4),
    );

    return SaListTile(
      leading: checkboxAlignment == IconAlignment.start ? checkboxWidget : leading,
      title: title,
      subtitle: subtitle,
      trailing: checkboxAlignment == IconAlignment.end ? checkboxWidget : trailing,
      contentPadding: contentPadding,
      constraints: constraints,
      borderRadius: borderRadius,
      enabled: enabled,
      tileColor: _resolveColor(context),
      onTap: enabled ? () => onChanged?.call(!value) : null,
      onLongPress: onLongPress,
    );
  }
}
