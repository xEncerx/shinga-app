import 'package:auto_route/auto_route.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../../core/core.dart';
import '../../../data/models/user/relations/relations.dart';
import '../../../i18n/strings.g.dart';

class BookMarksChart extends StatefulWidget {
  const BookMarksChart({
    super.key,
    required this.bookmarksCount,
  });

  final BookMarksCount bookmarksCount;

  @override
  State<BookMarksChart> createState() => _BookMarksChartState();
}

class _BookMarksChartState extends State<BookMarksChart> {
  int touchedIndex = -1;

  @override
  Widget build(BuildContext context) {
    final t = Translations.of(context);

    return SizedBox(
      height: 220,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Skeleton.replace(
            replacement: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
              ),
              child: Container(
                width: 100,
                height: 100,
                margin: const EdgeInsets.all(50),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Theme.of(context).scaffoldBackgroundColor,
                ),
                child: Center(
                  child: Text(
                    'Loading...',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
              ),
            ),
            child: Container(
              width: 90,
              height: 90,
              alignment: Alignment.center,
              child: Text(
                '${t.bookmarks.total}  ${widget.bookmarksCount.total}',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium.semiBold,
              ),
            ),
          ),
          PieChart(
            PieChartData(
              sections: showingSections(),
              sectionsSpace: 0,
              centerSpaceRadius: 50,
              pieTouchData: PieTouchData(touchCallback: _onSectionTouched),
            ),
          ),
        ],
      ),
    );
  }

  void _onSectionTouched(FlTouchEvent event, PieTouchResponse? response) {
    if (!event.isInterestedForInteractions || response == null || response.touchedSection == null) {
      if (touchedIndex != -1) {
        setState(() => touchedIndex = -1);
      }
      return;
    }

    final newTouchedIndex = response.touchedSection!.touchedSectionIndex;

    if (newTouchedIndex != touchedIndex) {
      setState(() => touchedIndex = newTouchedIndex);
    }

    if (event is FlTapDownEvent && touchedIndex != -1) {
      context.navigateTo(
        FavoritesRoute(
          initial: BookMarkType.aValues[touchedIndex],
        ),
      );
      setState(() => touchedIndex = -1);
    }
  }

  List<PieChartSectionData> showingSections() {
    return BookMarkType.aValues.map((
      bookmark,
    ) {
      final index = bookmark.index - 1; // Skip the 'notReading' bookmark
      final isTouched = index == touchedIndex;
      final value = widget.bookmarksCount.toJson()[bookmark.value] as int;

      return _getSectionData(
        value: value,
        color: bookmark.color,
        icon: bookmark.icon,
        isTouched: isTouched,
      );
    }).toList();
  }

  PieChartSectionData _getSectionData({
    required int value,
    required Color color,
    required IconData icon,
    required bool isTouched,
  }) {
    return PieChartSectionData(
      value: value.toDouble(),
      title: value.toString(),
      radius: isTouched ? 60.0 : 50.0,
      titleStyle: TextStyle(
        fontSize: isTouched ? 16.0 : 14.0,
        fontWeight: FontWeight.bold,
        color: Theme.of(context).colorScheme.onPrimary,
        shadows: const [Shadow(blurRadius: 2)],
      ),
      badgeWidget: _ChartBadge(
        size: isTouched ? 60.0 : 40.0,
        icon: icon,
        iconColor: color,
      ),
      titlePositionPercentageOffset: 0.4,
      badgePositionPercentageOffset: 1,
      color: color,
    );
  }
}

class _ChartBadge extends StatelessWidget {
  const _ChartBadge({
    required this.size,
    required this.icon,
    required this.iconColor,
  });

  final double size;
  final IconData icon;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: PieChart.defaultDuration,
      padding: EdgeInsets.all(size * 0.1),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Theme.of(context).colorScheme.onPrimary,
        border: Border.all(
          color: iconColor,
          width: 2,
        ),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.5),
            offset: const Offset(3, 3),
            blurRadius: 3,
          ),
        ],
      ),
      child: Icon(
        icon,
        color: iconColor,
      ),
    );
  }
}
