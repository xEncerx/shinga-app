import 'package:flutter/material.dart';
import 'package:ui_kit/ui_kit.dart';

/// A customizable dialog wrapper around [AlertDialog].
///
/// Provides sensible defaults for styling while allowing full customization
/// of title, content, and actions.
class SaAppDialog extends StatelessWidget {
  /// Creates an [SaAppDialog] widget.
  const SaAppDialog({
    required this.content,
    super.key,
    this.icon,
    this.iconPadding,
    this.iconColor,
    this.title,
    this.titlePadding,
    this.titleTextStyle,
    this.contentPadding,
    this.contentTextStyle,
    this.actions,
    this.actionsPadding,
    this.actionsAlignment,
    this.backgroundColor,
    this.elevation,
    this.shadowColor,
    this.insetPadding,
    this.clipBehavior,
    this.shape,
    this.alignment,
    this.constraints,
    this.scrollable = false,
  });

  /// The icon displayed at the top of the dialog.
  final SaIconSource? icon;

  /// Padding around the [icon].
  final EdgeInsetsGeometry? iconPadding;

  /// Color applied to the [icon].
  final Color? iconColor;

  /// The title widget displayed below the icon.
  final Widget? title;

  /// Padding around the [title].
  final EdgeInsetsGeometry? titlePadding;

  /// Style for the title text.
  final TextStyle? titleTextStyle;

  /// The main content of the dialog.
  final Widget content;

  /// Padding around the [content].
  final EdgeInsetsGeometry? contentPadding;

  /// Style for the content text.
  final TextStyle? contentTextStyle;

  /// The actions displayed at the bottom of the dialog.
  final List<Widget>? actions;

  /// Padding around the [actions].
  final EdgeInsetsGeometry? actionsPadding;

  /// Alignment of the [actions] row.
  final MainAxisAlignment? actionsAlignment;

  /// Background color of the dialog.
  final Color? backgroundColor;

  /// Elevation of the dialog.
  final double? elevation;

  /// Shadow color of the dialog.
  final Color? shadowColor;

  /// Padding around the dialog when displayed.
  final EdgeInsets? insetPadding;

  /// Clip behavior of the dialog.
  final Clip? clipBehavior;

  /// Shape of the dialog border.
  final ShapeBorder? shape;

  /// Alignment of the dialog within the screen.
  final AlignmentGeometry? alignment;

  /// Constraints for the dialog content.
  final BoxConstraints? constraints;

  /// Whether the content is scrollable.
  final bool scrollable;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return AlertDialog(
      title: Row(
        spacing: AppSpacing.s,
        children: [
          if (icon != null)
            SaDecoratedIcon(
              icon: icon!,
              iconColor: iconColor ?? colors.primary,
              padding: iconPadding,
            ),
          if (title != null) Expanded(child: title!),
        ],
      ),
      titlePadding: titlePadding,
      titleTextStyle: titleTextStyle ?? AppTextStyle.h6.copyWith(color: colors.onSurface),
      content: content,
      contentPadding: contentPadding,
      contentTextStyle:
          contentTextStyle ?? AppTextStyle.bodyL.copyWith(color: colors.onSurfaceVariant),
      actions: actions,
      actionsPadding: actionsPadding,
      actionsAlignment: actionsAlignment ?? MainAxisAlignment.end,
      backgroundColor: backgroundColor ?? colors.surface,
      elevation: elevation,
      shadowColor: shadowColor,
      insetPadding: insetPadding,
      clipBehavior: clipBehavior ?? Clip.none,
      shape:
          shape ??
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.xl),
          ),
      alignment: alignment,
      constraints: constraints,
      scrollable: scrollable,
    );
  }
}
