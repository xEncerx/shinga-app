import 'package:flutter/material.dart';
import 'package:shinga/domain/domain.dart';
import 'package:shinga/features/profile/widgets/widgets.dart';
import 'package:shinga/features/users/users.dart';
import 'package:ui_kit/ui_kit.dart';

/// Wide profile layout that keeps identity and analytics visible together.
class ProfileWideLayout extends StatelessWidget {
  /// Creates a [ProfileWideLayout] widget.
  const ProfileWideLayout({
    required this.user,
    required this.statistics,
    required this.isRefreshing,
    super.key,
  });

  /// Current user shown in the profile header.
  final UserEntity user;

  /// Current user statistics shown in summary and charts.
  final UserStatisticsEntity statistics;

  /// Whether statistics are being refreshed in the background.
  final bool isRefreshing;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1150),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: AppSpacing.l,
            children: [
              if (isRefreshing) const LinearProgressIndicator(minHeight: AppSpacing.xs),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 300,
                    child: Column(
                      spacing: AppSpacing.l,
                      children: [
                        ProfileHeaderCard(user: user),
                        ProfileSummaryGrid(statistics: statistics, columns: 1),
                      ],
                    ),
                  ),
                  const SizedBox(width: AppSpacing.l),
                  Expanded(
                    child: Column(
                      spacing: AppSpacing.l,
                      children: [
                        ProfileBookmarksCard(statistics: statistics.bookmarks),
                        ProfileRatingsCard(statistics: statistics.ratings),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
