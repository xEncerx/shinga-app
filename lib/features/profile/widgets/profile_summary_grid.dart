import 'package:flutter/material.dart';
import 'package:shinga/domain/domain.dart';
import 'package:shinga/features/titles/titles.dart';
import 'package:shinga/features/users/users.dart';
import 'package:shinga/i18n/i18n.dart';
import 'package:shinga/i18n/strings.g.dart';
import 'package:ui_kit/ui_kit.dart';

/// Grid of compact profile summary metrics.
class ProfileSummaryGrid extends StatelessWidget {
  /// Creates a [ProfileSummaryGrid] widget.
  const ProfileSummaryGrid({
    required this.statistics,
    required this.columns,
    super.key,
  });

  /// Statistics used to build summary values.
  final UserStatisticsEntity statistics;

  /// Number of columns in the grid.
  final int columns;

  @override
  Widget build(BuildContext context) {
    final t = Translations.of(context);
    final topBookmark = _topBookmark;
    final items = [
      _SummaryItem(
        value: statistics.bookmarks.total.toString(),
        description: t.profile.summary.bookmarks,
        icon: const SaIconSource.huge(HugeIconsStrokeRounded.allBookmark),
      ),
      _SummaryItem(
        value: topBookmark == null ? t.profile.summary.noTopStatus : topBookmark.i18n,
        description: t.profile.summary.topStatus,
        icon: topBookmark?.icon ?? const SaIconSource.huge(HugeIconsStrokeRounded.helpCircle),
      ),
      _SummaryItem(
        value: statistics.ratings.ratingsCount.toString(),
        description: t.profile.summary.ratedTitles,
        icon: const SaIconSource.huge(HugeIconsStrokeRounded.pencilEdit02),
      ),
      _SummaryItem(
        value: statistics.ratings.averageRating.toStringAsFixed(1),
        description: t.profile.summary.averageRating,
        icon: const SaIconSource.huge(HugeIconsStrokeRounded.starAward01),
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final spacing = AppSpacing.s * (columns - 1);
        final width = (constraints.maxWidth - spacing) / columns;

        return Wrap(
          spacing: AppSpacing.s,
          runSpacing: AppSpacing.s,
          children: [
            for (final item in items)
              SizedBox(
                width: width,
                child: SaStatisticBox(
                  value: item.value,
                  description: item.description,
                  icon: item.icon,
                  iconAlignment: SaIconAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                ),
              ),
          ],
        );
      },
    );
  }

  Bookmark? get _topBookmark {
    final entries = statistics.bookmarks.bookmarks.entries.where((entry) => entry.value > 0);
    if (entries.isEmpty) return null;

    return entries.reduce((left, right) => left.value >= right.value ? left : right).key;
  }
}

class _SummaryItem {
  const _SummaryItem({
    required this.value,
    required this.description,
    required this.icon,
  });

  final String value;
  final String description;
  final SaIconSource icon;
}
