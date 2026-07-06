import 'package:flutter/material.dart';
import 'package:shinga/features/profile/widgets/widgets.dart';
import 'package:shinga/features/users/users.dart';
import 'package:shinga/i18n/strings.g.dart';
import 'package:ui_kit/ui_kit.dart';

/// Mobile tabs that switch between bookmark and rating charts.
class ProfileChartTabs extends StatefulWidget {
  /// Creates a [ProfileChartTabs] widget.
  const ProfileChartTabs({required this.statistics, super.key});

  /// Statistics displayed inside both tabs.
  final UserStatisticsEntity statistics;

  @override
  State<ProfileChartTabs> createState() => _ProfileChartTabsState();
}

class _ProfileChartTabsState extends State<ProfileChartTabs> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final t = Translations.of(context);

    return DefaultTabController(
      length: 2,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.s),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          spacing: AppSpacing.s,
          children: [
            TabBar(
              onTap: (index) => setState(() => _selectedIndex = index),
              tabs: [
                Tab(text: t.profile.bookmarks.title),
                Tab(text: t.profile.ratings.title),
              ],
            ),
            AnimatedSwitcher(
              duration: kTabScrollDuration,
              layoutBuilder: (currentChild, previousChildren) {
                return Stack(
                  alignment: Alignment.topCenter,
                  children: [...previousChildren, ?currentChild],
                );
              },
              child: KeyedSubtree(
                key: ValueKey(_selectedIndex),
                child: _selectedIndex == 0
                    ? ProfileBookmarksCard(statistics: widget.statistics.bookmarks)
                    : ProfileRatingsCard(statistics: widget.statistics.ratings),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
