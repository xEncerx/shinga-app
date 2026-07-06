import 'package:flutter/material.dart';
import 'package:shinga/features/profile/widgets/widgets.dart';
import 'package:shinga/features/users/users.dart';
import 'package:shinga/i18n/strings.g.dart';
import 'package:ui_kit/ui_kit.dart';

/// Card that displays rating statistics and score distribution.
class ProfileRatingsCard extends StatelessWidget {
  /// Creates a [ProfileRatingsCard] widget.
  const ProfileRatingsCard({required this.statistics, super.key});

  /// Rating statistics to display.
  final UserRatingStatisticsEntity statistics;

  @override
  Widget build(BuildContext context) {
    final t = Translations.of(context);

    return SaSectionCard.transparent(
      headerIcon: const SaIcon(icon: SaIconSource.huge(HugeIconsStrokeRounded.starCircle)),
      headerLabel: SaText(t.profile.ratings.title),
      child: statistics.ratingsCount == 0
          ? SaStateMessage.empty(
              title: t.profile.ratings.emptyTitle,
              description: t.profile.ratings.emptyDescription,
            )
          : Padding(
              padding: const EdgeInsets.only(top: AppSpacing.m),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 550),
                  child: UserRatingsBarChart(ratings: statistics.ratingsDistribution),
                ),
              ),
            ),
    );
  }
}
