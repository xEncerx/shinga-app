import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:shinga/core/core.dart';
import 'package:shinga/features/profile/widgets/widgets.dart';
import 'package:shinga/features/users/users.dart';
import 'package:shinga/i18n/strings.g.dart';
import 'package:ui_kit/ui_kit.dart';

/// Card that displays bookmark statistics and status distribution.
class ProfileBookmarksCard extends StatelessWidget {
  /// Creates a [ProfileBookmarksCard] widget.
  const ProfileBookmarksCard({required this.statistics, super.key});

  /// Bookmark statistics to display.
  final UserBookmarkStatisticsEntity statistics;

  @override
  Widget build(BuildContext context) {
    final t = Translations.of(context);

    return SaSectionCard.transparent(
      headerIcon: const SaIcon(icon: SaIconSource.huge(HugeIconsStrokeRounded.allBookmark)),
      headerLabel: SaText(t.profile.bookmarks.title),
      child: statistics.total == 0
          ? SaStateMessage.empty(
              title: t.profile.bookmarks.emptyTitle,
              description: t.profile.bookmarks.emptyDescription,
            )
          : Column(
              mainAxisSize: MainAxisSize.min,
              spacing: AppSpacing.xl,
              children: [
                Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 250),
                    child: UserBookmarksPieChart(
                      bookmarks: statistics.bookmarks,
                      total: statistics.total,
                      onBookmarkTap: (bookmark) =>
                          context.navigateTo(FavoritesRoute(initialBookmark: bookmark)),
                    ),
                  ),
                ),
                ProfileBookmarkLegend(bookmarks: statistics.bookmarks),
              ],
            ),
    );
  }
}
