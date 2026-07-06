import 'package:flutter/material.dart';
import 'package:shinga/domain/domain.dart';
import 'package:shinga/features/profile/widgets/widgets.dart';
import 'package:shinga/features/users/users.dart';
import 'package:ui_kit/ui_kit.dart';

/// Mobile profile layout with compact summary and tabbed charts.
class ProfileNarrowLayout extends StatelessWidget {
  /// Creates a [ProfileNarrowLayout] widget.
  const ProfileNarrowLayout({
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
      padding: const EdgeInsets.all(AppSpacing.l),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: AppSpacing.l,
        children: [
          if (isRefreshing) const LinearProgressIndicator(minHeight: AppSpacing.xs),
          ProfileHeaderCard(user: user),
          ProfileSummaryGrid(statistics: statistics, columns: 2),
          ProfileChartTabs(statistics: statistics),
        ],
      ),
    );
  }
}
