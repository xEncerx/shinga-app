import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shinga/domain/domain.dart';
import 'package:shinga/features/features.dart';
import 'package:shinga/i18n/strings.g.dart';
import 'package:ui_kit/ui_kit.dart';

/// A chart showing user bookmark counts.
class UserBookmarksPieChart extends StatefulWidget {
  /// Creates a [UserBookmarksPieChart] widget.
  const UserBookmarksPieChart({
    required this.bookmarks,
    required this.total,
    super.key,
    this.onBookmarkTap,
  });

  /// Counts to render for each supported bookmark status.
  final Map<Bookmark, int> bookmarks;

  /// Total count of user bookmarks.
  final int total;

  /// Called when the user selects a visible bookmark section.
  final ValueChanged<Bookmark>? onBookmarkTap;

  @override
  State<UserBookmarksPieChart> createState() => _UserBookmarksPieChartState();
}

class _UserBookmarksPieChartState extends State<UserBookmarksPieChart> {
  int touchedIndex = -1;

  List<Bookmark> get _visibleBookmarks =>
      Bookmark.aValues.where((bookmark) => (widget.bookmarks[bookmark] ?? 0) > 0).toList();

  @override
  Widget build(BuildContext context) {
    final visibleBookmarks = _visibleBookmarks;
    if (visibleBookmarks.isEmpty) {
      return const SizedBox.shrink();
    }

    return AspectRatio(
      aspectRatio: 1,
      child: LayoutBuilder(
        builder: (_, constraints) {
          final chartSize = constraints.biggest.shortestSide;
          if (!chartSize.isFinite || chartSize <= 0) {
            return const SizedBox.shrink();
          }

          return Stack(
            alignment: Alignment.center,
            children: [
              PieChart(
                PieChartData(
                  sections: showingSections(
                    chartSize: chartSize,
                    visibleBookmarks: visibleBookmarks,
                  ),
                  sectionsSpace: 0,
                  centerSpaceRadius: chartSize * 0.2,
                  pieTouchData: PieTouchData(touchCallback: _onSectionTouched),
                ),
              ),
              _CenterTotal(size: chartSize * 0.35, total: widget.total),
            ],
          );
        },
      ),
    );
  }

  Future<void> _onSectionTouched(FlTouchEvent event, PieTouchResponse? response) async {
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

    final eventAction =
        defaultTargetPlatform == TargetPlatform.android ||
            defaultTargetPlatform == TargetPlatform.iOS
        ? FlTapDownEvent
        : FlTapUpEvent;

    if (event.runtimeType == eventAction && newTouchedIndex != -1) {
      final visibleBookmarks = _visibleBookmarks;
      if (newTouchedIndex < visibleBookmarks.length) {
        widget.onBookmarkTap?.call(visibleBookmarks[newTouchedIndex]);
      }
      setState(() => touchedIndex = -1);
    }
  }

  List<PieChartSectionData> showingSections({
    required double chartSize,
    required List<Bookmark> visibleBookmarks,
  }) {
    return visibleBookmarks.indexed.map((entry) {
      final (index, bookmark) = entry;
      final value = widget.bookmarks[bookmark]!;
      final isTouched = index == touchedIndex;

      return _getSectionData(
        value: value,
        bookmark: bookmark,
        chartSize: chartSize,
        isTouched: isTouched,
      );
    }).toList();
  }

  PieChartSectionData _getSectionData({
    required int value,
    required Bookmark bookmark,
    required double chartSize,
    required bool isTouched,
  }) {
    return PieChartSectionData(
      value: value.toDouble(),
      title: value.toString(),
      radius: chartSize * (isTouched ? 0.28 : 0.24),
      titleStyle: AppTextStyle.titleS.copyWith(
        fontSize: chartSize * (isTouched ? 0.09 : 0.07),
        color: Theme.of(context).colorScheme.onPrimary,
      ),
      badgeWidget: _ChartBadge(size: chartSize * (isTouched ? 0.6 : 0.5), bookmark: bookmark),
      titlePositionPercentageOffset: 0.4,
      badgePositionPercentageOffset: 1,
      color: bookmark.highlightColor(context.appColors),
    );
  }
}

class _CenterTotal extends StatelessWidget {
  const _CenterTotal({required this.size, required this.total});

  final double size;
  final int total;

  @override
  Widget build(BuildContext context) {
    final t = Translations.of(context);

    return SizedBox.square(
      dimension: size,
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SaText(
              t.profile.totalBookmarks,
              textAlign: TextAlign.center,
              style: AppTextStyle.captionS.copyWith(color: context.colors.onSurfaceVariant),
            ),
            SaText(
              total.toString(),
              textAlign: TextAlign.center,
              style: AppTextStyle.titleM.copyWith(color: context.colors.onSurface),
            ),
          ],
        ),
      ),
    );
  }
}

class _ChartBadge extends StatelessWidget {
  const _ChartBadge({required this.size, required this.bookmark});

  final double size;
  final Bookmark bookmark;

  @override
  Widget build(BuildContext context) {
    final bookmarkColor = bookmark.highlightColor(context.appColors);
    final colorScheme = context.colors;

    return AnimatedScale(
      scale: size / 100,
      duration: PieChart.defaultDuration,
      child: DecoratedBox(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: colorScheme.onPrimary,
          border: Border.all(color: bookmarkColor ?? colorScheme.outlineVariant, width: 2),
        ),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xs),
          child: SaIcon(icon: bookmark.icon, color: bookmarkColor),
        ),
      ),
    );
  }
}
