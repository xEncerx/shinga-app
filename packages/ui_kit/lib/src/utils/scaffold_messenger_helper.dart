import 'package:flutter/material.dart';
import 'package:ui_kit/ui_kit.dart';

/// A static utility class for displaying [SnackBar] messages via [ScaffoldMessenger].
class ScaffoldMessengerHelper {
  ScaffoldMessengerHelper._();

  static const _snackBarDuration = Duration(seconds: 5);

  /// Shows a generic snack bar message with an optional [icon] and [subtitle].
  static void showMessage({
    required BuildContext context,
    required String title,
    String? subtitle,
    SaIconSource? icon,
    Color? iconColor,
  }) {
    final snackBar = createSnackBar(
      title: title,
      subtitle: subtitle,
      prefixWidget: icon != null
          ? SaIcon(
              icon: icon,
              color: iconColor ?? context.colors.primary,
            )
          : null,
    );

    if (context.mounted) {
      ScaffoldMessenger.of(context)
        ..removeCurrentSnackBar()
        ..showSnackBar(snackBar);
    }
  }

  /// Shows a snack bar with an indeterminate loading indicator.
  static void showLoading({
    required BuildContext context,
    required String title,
  }) {
    final snackBar = createSnackBar(
      title: title,
      prefixWidget: const SizedBox(
        width: 24,
        height: 24,
        child: CircularProgressIndicator(strokeWidth: 2),
      ),
    );

    if (context.mounted) {
      ScaffoldMessenger.of(context)
        ..removeCurrentSnackBar()
        ..showSnackBar(snackBar);
    }
  }

  /// Shows an error snack bar with an alert icon.
  static void showError({
    required BuildContext context,
    required String title,
    String? subtitle,
    SaIconSource? icon,
    Color? iconColor,
  }) {
    final snackBar = createSnackBar(
      title: title,
      subtitle: subtitle,
      prefixWidget: SaIcon(
        icon: icon ?? const SaIconSource.huge(HugeIconsStrokeRounded.alertCircle),
        color: iconColor ?? context.colors.error,
      ),
    );

    if (context.mounted) {
      ScaffoldMessenger.of(context)
        ..removeCurrentSnackBar()
        ..showSnackBar(snackBar);
    }
  }

  /// Creates a [SnackBar] with the given [title], optional [subtitle],
  /// and an optional [prefixWidget] (e.g. an icon or loading indicator).
  static SnackBar createSnackBar({
    required String title,
    String? subtitle,
    Widget? prefixWidget,
    Duration duration = _snackBarDuration,
  }) {
    return SnackBar(
      content: Row(
        spacing: AppSpacing.l,
        children: [
          if (prefixWidget != null) ...[
            prefixWidget,
          ],
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SaText(
                  title,
                  style: AppTextStyle.bodyBold.copyWith(color: Colors.black),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
                if (subtitle != null)
                  SaText(
                    subtitle,
                    style: AppTextStyle.body.copyWith(color: Colors.black),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2,
                  ),
              ],
            ),
          ),
        ],
      ),
      duration: duration,
    );
  }

  /// Hides the currently displayed snack bar, if any.
  static void hide(BuildContext context) => ScaffoldMessenger.of(context).removeCurrentSnackBar();

  /// Clears all snack bars from the scaffold messenger queue.
  static void clearAll(BuildContext context) => ScaffoldMessenger.of(context).clearSnackBars();
}
