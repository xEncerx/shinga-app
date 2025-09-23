import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../core/core.dart';
import '../../../data/data.dart';
import '../../../i18n/strings.g.dart';

/// A section displaying various statistics about a title, such as rating, views, chapters, and release year.
///
/// With [StatisticItem] widgets for each statistic.
class TitleStatisticSection extends StatelessWidget {
  const TitleStatisticSection({
    super.key,
    required this.rating,
    required this.views,
    required this.chapters,
    required this.date,
  });

  static final _formatter = NumberFormat.compact();

  /// The average rating of the title.
  final double rating;

  /// The total number of views the title has received.
  final int views;

  /// The total number of chapters available for the title.
  final int chapters;

  /// The release time information of the title.
  final TitleReleaseTime date;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        StatisticItem(
          icon: Icons.star_rate_rounded,
          value: rating.toStringAsFixed(1),
          label: t.titleInfo.rating,
        ),
        StatisticItem(
          icon: Icons.remove_red_eye_outlined,
          value: _formatter.format(views),
          label: t.titleInfo.views,
        ),
        StatisticItem(
          icon: Icons.menu_book_rounded,
          value: chapters.toString(),
          label: t.titleInfo.chapters,
        ),
        StatisticItem(
          icon: Icons.calendar_today,
          value: date.from?.year.toString() ?? 'N/A',
          label: t.titleInfo.year,
        ),
      ],
    );
  }
}
