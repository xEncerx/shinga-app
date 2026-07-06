import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shinga/domain/domain.dart';
import 'package:shinga/features/features.dart';
import 'package:shinga/i18n/i18n.dart';
import 'package:shinga/i18n/strings.g.dart';
import 'package:ui_kit/ui_kit.dart';

/// Widget that displays a dropdown for selecting a bookmark status for a title.
class TitleDetailBookmarkDropdown extends StatelessWidget {
  /// Creates a [TitleDetailBookmarkDropdown] widget.
  const TitleDetailBookmarkDropdown({super.key});

  @override
  Widget build(BuildContext context) {
    final t = Translations.of(context);

    return SizedBox(
      height: 42,
      child: BlocSelector<TitleDetailCubit, TitleDetailState, Bookmark?>(
        selector: (state) => state.data.userData?.bookmark,
        builder: (_, userBookmark) {
          return SaDropdown<Bookmark>(
            value: userBookmark,
            items: Bookmark.values
                .map(
                  (bookmark) => SaDropdownItem(
                    value: bookmark,
                    label: SaIconText(
                      label: SaText(bookmark.i18n),
                      icon: SaIcon(
                        icon: bookmark.icon,
                        size: 20,
                      ),
                    ),
                  ),
                )
                .toList(),
            hintText: t.titleDetail.addToBookmarks,
            onChanged: (value) async {
              if (value == null) return;
              // If the user doesn't have a bookmark, add the title to their list with the selected bookmark status.
              if (userBookmark == null) {
                await context.read<TitleDetailCubit>().addToBookmark(value);
                // If the title is already in the user's list, then we update its bookmark status to the selected one.
              } else {
                await context.read<TitleDetailCubit>().changeBookmark(value);
              }
            },
          );
        },
      ),
    );
  }
}
