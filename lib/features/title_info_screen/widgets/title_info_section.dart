import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';
import 'package:timeago/timeago.dart' as timeago;

import '../../../core/core.dart';
import '../../../data/data.dart';
import '../../../i18n/strings.g.dart';

/// A section displaying various information about a title.
class TitleInfoSection extends StatelessWidget {
  const TitleInfoSection({
    super.key,
    required this.scoredBy,
    required this.status,
    required this.type,
    required this.inAppRating,
    required this.inAppScoredBy,
    required this.updatedAt,
    required this.languageCode,
  });

  /// The number of users who have rated the title.
  final int scoredBy;

  /// The current status of the title (e.g., ongoing, completed).
  final TitleStatus status;

  /// The type of the title (e.g., manga, novel).
  final TitleType type;

  /// The average rating of the title. (Shinga-api only)
  final double inAppRating;

  /// The number of users who have rated the title. (Shinga-api only)
  final int inAppScoredBy;

  /// The last update time of the title.
  final DateTime updatedAt;

  /// The language code for formatting the last update time text.
  final String languageCode;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          spacing: 5,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            IconWithText(
              text: t.titleInfo.info,
              icon: Icon(
                Icons.info_outline,
                size: 22,
                color: theme.colorScheme.primary,
              ),
              textStyle: theme.textTheme.titleMedium.semiBold,
            ),
            _TitleInfo(
              t.titleInfo.scoredBy,
              scoredBy.toString(),
              Icons.group,
            ),
            _TitleInfo(
              t.titleInfo.status,
              status.i18n,
              Icons.history,
            ),
            _TitleInfo(
              t.titleInfo.type,
              type.i18n,
              Icons.source,
            ),
            _TitleInfo(
              t.titleInfo.inAppRating,
              inAppRating.toStringAsFixed(1),
              Icons.star_rounded,
            ),
            _TitleInfo(
              t.titleInfo.inAppScoredBy,
              inAppScoredBy.toString(),
              Icons.group,
            ),
            _TitleInfo(
              t.titleInfo.lastUpdateTime,
              timeago.format(
                updatedAt,
                locale: languageCode,
              ),
              Icons.update,
            ),
          ],
        ),
      ),
    );
  }
}

class _TitleInfo extends StatelessWidget {
  const _TitleInfo(this.title, this.value, this.icon);

  final String title;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(left: 15).copyWith(right: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(
            child: IconWithText(
              text: title,
              maxLines: 2,
              icon: Icon(
                icon,
                size: 18,
                color: theme.colorScheme.primary.withValues(alpha: 0.8),
              ),
              textStyle: theme.textTheme.titleSmall.ellipsis,
            ),
          ),
          Text(value.capitalize),
        ],
      ),
    );
  }
}
