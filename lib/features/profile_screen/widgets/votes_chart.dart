import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../../data/data.dart';

class VotesChart extends StatelessWidget {
  const VotesChart({super.key, required this.userVotes});

  final UserVotes userVotes;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SizedBox(
      width: 300,
      height: 280,
      child: BarChart(
        BarChartData(
          barGroups: _getBarGroups(theme),
          rotationQuarterTurns: 1,
          titlesData: FlTitlesData(
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 30,
                getTitlesWidget: getTitles,
              ),
            ),
            leftTitles: const AxisTitles(),
            topTitles: const AxisTitles(),
            rightTitles: const AxisTitles(),
          ),
          borderData: FlBorderData(show: false),
          barTouchData: BarTouchData(
            enabled: false,
            touchTooltipData: BarTouchTooltipData(
              getTooltipColor: (group) => Colors.transparent,
              tooltipPadding: const EdgeInsets.only(top: 2),
              tooltipMargin: 5,
              getTooltipItem:
                  (
                    BarChartGroupData group,
                    int groupIndex,
                    BarChartRodData rod,
                    int rodIndex,
                  ) {
                    return BarTooltipItem(
                      rod.toY.round().toString(),
                      TextStyle(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    );
                  },
            ),
          ),
          gridData: const FlGridData(show: false),
          alignment: BarChartAlignment.spaceAround,
          maxY: _getMaxVoteCount().toDouble() + 1,
        ),
      ),
    );
  }

  Widget getTitles(double value, TitleMeta meta) {
    return SideTitleWidget(
      meta: meta,
      space: 4,
      child: Text('${value.toInt()}'),
    );
  }

  List<BarChartGroupData> _getBarGroups(ThemeData theme) {
    return _getVotesData().asMap().entries.map((entry) {
      final index = entry.key;
      final value = entry.value;
      return BarChartGroupData(
        x: 10 - index,
        barRods: [
          BarChartRodData(
            toY: value.toDouble(),
            color: theme.colorScheme.primary,
          ),
        ],
        showingTooltipIndicators: value > 0 ? [0] : null,
      );
    }).toList();
  }

  List<int> _getVotesData() {
    return [
      userVotes.vote_10,
      userVotes.vote_9,
      userVotes.vote_8,
      userVotes.vote_7,
      userVotes.vote_6,
      userVotes.vote_5,
      userVotes.vote_4,
      userVotes.vote_3,
      userVotes.vote_2,
      userVotes.vote_1,
    ];
  }

  int _getMaxVoteCount() {
    final votes = _getVotesData();
    final max = votes.reduce((a, b) => a > b ? a : b);
    return max > 0 ? max : 1;
  }
}
