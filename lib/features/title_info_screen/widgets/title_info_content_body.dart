import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:readmore/readmore.dart';
import 'package:timeago/timeago.dart' as timeago;

import '../../../core/core.dart';
import '../../../data/data.dart';
import '../../../i18n/strings.g.dart';
import '../../features.dart';

class TitleInfoContentBody extends StatelessWidget {
  const TitleInfoContentBody({
    super.key,
    required this.titleData,
    required this.urlController,
  });

  final TitleWithUserData titleData;
  final TextEditingController urlController;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final formatter = NumberFormat.compact();
    final appSettings = context.read<SettingsCubit>().settings;
    final title = titleData.title;

    return Column(
      spacing: 10,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TitleHeadlineText(
          displayName: appSettings.language == AppLocale.ru
              ? title.nameRu ?? '???'
              : title.nameEn ?? '???',
          nameRu: title.nameRu,
          nameEn: title.nameEn,
          altNames: title.altNames,
        ),
        // Changeable URL and Bookmark Buttons
        BlocBuilder<TitleInfoBloc, TitleInfoState>(
          builder: (context, state) {
            final stateTitleData = state is TitleInfoLoaded ? state.titleData : titleData;

            return Row(
              spacing: 5,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: TitleReadButton(
                    titleData: stateTitleData,
                    urlController: urlController,
                  ),
                ),
                TitleBookmarkButton(
                  titleData: stateTitleData,
                ),
              ],
            );
          },
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            StatisticItem(
              icon: Icons.star_rate_rounded,
              value: title.rating.toStringAsFixed(1),
              label: t.titleInfo.rating,
            ),
            StatisticItem(
              icon: Icons.remove_red_eye_outlined,
              value: formatter.format(title.views),
              label: t.titleInfo.views,
            ),
            StatisticItem(
              icon: Icons.menu_book_rounded,
              value: title.chapters.toString(),
              label: t.titleInfo.chapters,
            ),
            StatisticItem(
              icon: Icons.calendar_today,
              value: title.date.from?.year.toString() ?? 'N/A',
              label: t.titleInfo.year,
            ),
          ],
        ),
        const SizedBox(height: 5),
        // Title Info Section
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
          title.scoredBy.toString(),
          Icons.group,
        ),
        _TitleInfo(
          t.titleInfo.status,
          title.status.i18n,
          Icons.history,
        ),
        _TitleInfo(
          t.titleInfo.type,
          title.type.i18n,
          Icons.source,
        ),
        _TitleInfo(
          t.titleInfo.inAppRating,
          title.inAppRating.toStringAsFixed(1),
          Icons.star_rounded,
        ),
        _TitleInfo(
          t.titleInfo.inAppScoredBy,
          title.inAppScoredBy.toString(),
          Icons.group,
        ),
        _TitleInfo(
          t.titleInfo.lastUpdateTime,
          timeago.format(
            title.updatedAt,
            locale: appSettings.language.languageCode,
          ),
          Icons.update,
        ),
        // Genres Section
        IconWithText(
          text: t.titleInfo.genres,
          icon: Icon(
            Icons.category_rounded,
            size: 22,
            color: theme.colorScheme.primary,
          ),
          textStyle: theme.textTheme.titleMedium.semiBold,
        ),
        Wrap(
          spacing: 8,
          runSpacing: 4,
          children: title.genres
              .map(
                (genre) => Chip(
                  label: Text(
                    appSettings.language == AppLocale.ru ? genre.ru : genre.en,
                  ),
                ),
              )
              .toList(),
        ),
        // Authors Section
        IconWithText(
          text: t.titleInfo.authors,
          icon: Icon(
            Icons.person_rounded,
            size: 22,
            color: theme.colorScheme.primary,
          ),
          textStyle: theme.textTheme.titleMedium.semiBold,
        ),
        Wrap(
          spacing: 8,
          runSpacing: 4,
          children: title.authors
              .map(
                (author) => Chip(label: Text(author)),
              )
              .toList(),
        ),
        // Description Section
        IconWithText(
          text: t.titleInfo.description,
          icon: Icon(
            Icons.description,
            size: 22,
            color: theme.colorScheme.primary,
          ),
          textStyle: theme.textTheme.titleMedium.semiBold,
        ),
        ReadMoreText(
          appSettings.language == AppLocale.ru
              ? title.description.ru ?? 'N/A'
              : title.description.en ?? 'N/A',
          colorClickableText: theme.colorScheme.primary,
          trimExpandedText: t.titleInfo.trimExpanded,
          trimCollapsedText: t.titleInfo.trimCollapsed,
        ),
        const SizedBox(height: 0),
      ],
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
      padding: const EdgeInsets.only(left: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconWithText(
            text: title,
            icon: Icon(
              icon,
              size: 18,
              color: theme.colorScheme.primary.withValues(alpha: 0.8),
            ),
            textStyle: theme.textTheme.titleSmall,
          ),
          Text(value.capitalize),
        ],
      ),
    );
  }
}
