import 'dart:math' as math;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'package:ui_kit/ui_kit.dart';

const _firstRating = 1;
const _lastRating = 10;

/// A bar chart showing how many titles the user rated with each score.
class UserRatingsBarChart extends StatefulWidget {
  /// Creates a [UserRatingsBarChart] widget.
  const UserRatingsBarChart({required this.ratings, super.key});

  /// Counts to render for each rating from 1 to 10.
  final Map<int, int> ratings;

  @override
  State<UserRatingsBarChart> createState() => _UserRatingsBarChartState();
}

class _UserRatingsBarChartState extends State<UserRatingsBarChart> {
  int _touchedRating = -1;

  double get _maxY {
    final maxCount = List.generate(
      _lastRating,
      (index) => widget.ratings[index + _firstRating] ?? 0,
    ).fold(0, math.max);

    if (maxCount <= 0) return _lastRating / 2;

    return ((maxCount + 4) ~/ 5 * 5).toDouble();
  }

  double get _horizontalInterval => _maxY <= _lastRating / 2 ? _firstRating.toDouble() : _maxY / 5;

  @override
  Widget build(BuildContext context) {
    final isWide = ResponsiveBreakpoints.of(context).largerThan(MOBILE);

    return AspectRatio(
      aspectRatio: isWide ? 2 : 1.4,
      child: BarChart(
        BarChartData(
          minY: 0,
          maxY: _maxY,
          alignment: BarChartAlignment.spaceAround,
          barGroups: _barGroups(context, isWide: isWide),
          barTouchData: BarTouchData(
            enabled: true,
            handleBuiltInTouches: false,
            touchCallback: _onBarTouched,
          ),
          borderData: FlBorderData(show: false),
          gridData: FlGridData(
            drawVerticalLine: false,
            horizontalInterval: _horizontalInterval,
            getDrawingHorizontalLine: (_) =>
                FlLine(color: context.colors.outlineVariant, strokeWidth: 1),
          ),
          titlesData: FlTitlesData(
            topTitles: const AxisTitles(),
            rightTitles: const AxisTitles(),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                interval: _horizontalInterval,
                reservedSize: isWide ? 40 : 24,
                getTitlesWidget: _LeftTitle.new,
              ),
            ),
            bottomTitles: const AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 24,
                getTitlesWidget: _BottomTitle.new,
              ),
            ),
          ),
        ),
        duration: const Duration(milliseconds: 250),
      ),
    );
  }

  void _onBarTouched(FlTouchEvent event, BarTouchResponse? response) {
    if (!event.isInterestedForInteractions || response?.spot == null) {
      if (_touchedRating != -1) {
        setState(() => _touchedRating = -1);
      }
      return;
    }

    final rating = response!.spot!.touchedBarGroup.x;
    if (rating != _touchedRating) {
      setState(() => _touchedRating = rating);
    }
  }

  List<BarChartGroupData> _barGroups(BuildContext context, {required bool isWide}) {
    return List.generate(_lastRating, (index) {
      final rating = index + _firstRating;
      final count = widget.ratings[rating] ?? 0;
      final isTouched = rating == _touchedRating;

      return BarChartGroupData(
        x: rating,
        barRods: [
          BarChartRodData(
            toY: count.toDouble(),
            width: isWide ? 20 : 16,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(AppRadius.s)),
            color: isTouched ? context.colors.primary : context.appColors.ratingColor,
            backDrawRodData: BackgroundBarChartRodData(
              show: true,
              toY: _maxY,
              color: context.colors.surfaceContainerHighest,
            ),
          ),
        ],
      );
    });
  }
}

class _BottomTitle extends StatelessWidget {
  const _BottomTitle(this.value, this.meta);

  final double value;
  final TitleMeta meta;

  @override
  Widget build(BuildContext context) {
    final rating = value.toInt();
    if (rating < _firstRating || rating > _lastRating) {
      return const SizedBox.shrink();
    }

    return SideTitleWidget(
      meta: meta,
      child: SaText(
        rating.toString(),
        style: AppTextStyle.captionL.copyWith(color: context.colors.onSurfaceVariant),
      ),
    );
  }
}

class _LeftTitle extends StatelessWidget {
  const _LeftTitle(this.value, this.meta);

  final double value;
  final TitleMeta meta;

  @override
  Widget build(BuildContext context) {
    return SideTitleWidget(
      meta: meta,
      child: SaText(
        value.toInt().toString(),
        style: AppTextStyle.captionS.copyWith(color: context.colors.onSurfaceVariant),
      ),
    );
  }
}
