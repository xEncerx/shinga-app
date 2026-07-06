import 'package:flutter/material.dart';
import 'package:ui_kit/src/src.dart';

/// A styled list tile that follows the app design system.
///
/// Wraps Flutter's [ListTile] with app-themed defaults.
class SaListTile extends StatelessWidget {
  /// Creates a [SaListTile].
  const SaListTile({
    this.leading,
    this.title,
    this.subtitle,
    this.trailing,
    this.contentPadding,
    this.tileColor,
    this.borderRadius,
    this.enabled = true,
    this.constraints,
    this.onTap,
    this.onLongPress,
    super.key,
  });

  /// Widget placed at the start of the tile.
  final Widget? leading;

  /// Primary content of the tile.
  final Widget? title;

  /// Additional content displayed below [title].
  final Widget? subtitle;

  /// Widget placed at the end of the tile.
  final Widget? trailing;

  /// Padding around the tile content.
  ///
  /// Defaults to horizontal [AppSpacing.m].
  final EdgeInsetsGeometry? contentPadding;

  /// Corner radius of the tile.
  ///
  /// Defaults to [AppRadius.card].
  final double? borderRadius;

  /// Whether the tile is interactive.
  final bool enabled;

  /// Fill color of the tile background.
  ///
  /// Defaults to primary theme color at 20 % opacity.
  final Color? tileColor;

  /// Constraints applied to the tile.
  final BoxConstraints? constraints;

  /// Called when the tile is tapped.
  final VoidCallback? onTap;

  /// Called when the tile is long-pressed.
  final VoidCallback? onLongPress;

  bool get _isEnabled => enabled && (onTap != null || onLongPress != null);

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colors;

    final fillColor = tileColor ?? colorScheme.primary.withValues(alpha: 0.2);
    final effectiveConstraints = constraints ?? const BoxConstraints(minHeight: 48);
    final effectivePadding = contentPadding ?? const EdgeInsets.symmetric(horizontal: AppSpacing.m);
    final effectiveBorderRadius = BorderRadius.circular(borderRadius ?? AppRadius.card);

    return ConstrainedBox(
      constraints: effectiveConstraints,
      child: Material(
        color: fillColor,
        borderRadius: effectiveBorderRadius,
        child: InkWell(
          onTap: enabled ? onTap : null,
          onLongPress: enabled ? onLongPress : null,
          mouseCursor: _isEnabled ? SystemMouseCursors.click : SystemMouseCursors.basic,
          borderRadius: effectiveBorderRadius,
          child: Padding(
            padding: effectivePadding,
            child: Row(
              spacing: AppSpacing.s,
              children: [
                ?leading,
                if (title != null)
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        DefaultTextStyle(
                          style: AppTextStyle.bodyBold.copyWith(
                            color: colorScheme.onSurface,
                          ),
                          child: title!,
                        ),
                        // Apply default text theme
                        if (subtitle != null)
                          DefaultTextStyle(
                            style: AppTextStyle.captionL.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                            child: subtitle!,
                          ),
                      ],
                    ),
                  ),
                ?trailing,
              ],
            ),
          ),
        ),
      ),
    );
  }
}
