import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:shinga/core/core.dart';
import 'package:shinga/domain/domain.dart';
import 'package:shinga/features/titles/titles.dart';
import 'package:shinga/i18n/i18n.dart';
import 'package:ui_kit/ui_kit.dart';

/// Legend that explains bookmark chart sections and links to filtered favorites.
class ProfileBookmarkLegend extends StatelessWidget {
  /// Creates a [ProfileBookmarkLegend] widget.
  const ProfileBookmarkLegend({required this.bookmarks, super.key});

  /// Bookmark counts by status.
  final Map<Bookmark, int> bookmarks;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppSpacing.s,
      runSpacing: AppSpacing.s,
      children: [
        for (final bookmark in Bookmark.aValues)
          _BookmarkLegendChip(
            bookmark: bookmark,
            count: bookmarks[bookmark] ?? 0,
          ),
      ],
    );
  }
}

class _BookmarkLegendChip extends StatelessWidget {
  const _BookmarkLegendChip({required this.bookmark, required this.count});

  final Bookmark bookmark;
  final int count;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final bookmarkColor = bookmark.highlightColor(context.appColors) ?? colors.primary;

    return SaChip(
      label: '${bookmark.i18n} · $count',
      leadingIcon: bookmark.icon,
      onTap: () => context.navigateTo(FavoritesRoute(initialBookmark: bookmark)),
      color: bookmarkColor.withValues(alpha: 0.2),
    );
  }
}
