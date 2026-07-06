import 'package:flutter/material.dart';
import 'package:shinga/i18n/strings.g.dart';
import 'package:ui_kit/ui_kit.dart';

/// A search bar widget for the favorites screen.
class FavoritesSearchBar extends StatelessWidget {
  /// Creates a [FavoritesSearchBar] widget.
  const FavoritesSearchBar({super.key, this.bottom, this.actions, this.onTap});

  /// The bottom widget for the app bar.
  final PreferredSizeWidget? bottom;

  /// The actions for the app bar.
  final List<Widget>? actions;

  /// The callback when the search bar is tapped.
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final t = Translations.of(context);
    final colorScheme = context.colors;

    return AppBar(
      automaticallyImplyLeading: false,
      title: SaTextField(
        readOnly: true,
        mouseCursor: SystemMouseCursors.click,
        decoration: InputDecoration(
          hintText: t.favorites.searchBarTitle,
          filled: true,
          fillColor: colorScheme.surface,
          hintStyle: AppTextStyle.titleM.copyWith(color: colorScheme.onSurfaceVariant),
          prefixIcon: SaIcon(
            icon: const SaIconSource.huge(HugeIconsStrokeRounded.search01),
            color: colorScheme.onSurfaceVariant,
          ),
          border: const OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(AppRadius.full)),
            borderSide: BorderSide.none,
          ),
        ),
        onTap: onTap,
      ),
      bottom: bottom,
      actions: actions,
      actionsPadding: const EdgeInsets.only(right: AppSpacing.m),
    );
  }
}
