import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';
import 'package:group_button/group_button.dart';
import 'package:intl/intl.dart';
import 'package:readmore/readmore.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:timeago/timeago.dart' as timeago;

import '../../../core/core.dart';
import '../../../data/data.dart';
import '../../../i18n/strings.g.dart';
import '../../features.dart';

class MangaContentBody extends StatelessWidget {
  const MangaContentBody({
    super.key,
    required this.mangaData,
    required this.cubit,
    required this.urlController,
    required this.radioController,
    required this.isLoading,
  });

  final Manga mangaData;
  final MangaInfoCubit cubit;
  final TextEditingController urlController;
  final GroupButtonController radioController;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final formatter = NumberFormat.compact();

    return Skeletonizer(
      enabled: isLoading,
      containersColor: theme.colorScheme.primary.withValues(alpha: 0.05),
      effect: ShimmerEffect(
        baseColor: theme.colorScheme.primary.withOpacity(0.1),
        highlightColor: theme.colorScheme.primary.withOpacity(0.2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 10,
        children: [
          MangaTitleInfo(
            name: mangaData.name,
            altNames: mangaData.altNames,
          ),
          Row(
            spacing: 5,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: MangaReadButton(
                  mangaId: mangaData.id,
                  controller: urlController,
                  cubit: cubit,
                ),
              ),
              MangaSectionButton(
                mangaId: mangaData.id,
                controller: radioController,
                cubit: cubit,
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              MangaStatItem(
                icon: Icons.star_rate_rounded,
                value: mangaData.avgRating,
                label: t.titleInfo.rating,
              ),
              MangaStatItem(
                icon: Icons.remove_red_eye_outlined,
                value: formatter.format(mangaData.views),
                label: t.titleInfo.views,
              ),
              MangaStatItem(
                icon: Icons.menu_book_rounded,
                value: mangaData.chapters.toString(),
                label: t.titleInfo.chapters,
              ),
              MangaStatItem(
                icon: Icons.calendar_today,
                value: mangaData.year?.toString() ?? 'N/A',
                label: t.titleInfo.year,
              ),
            ],
          ),
          const SizedBox(height: 5),
          IconWithText(
            text: t.titleInfo.info,
            icon: Icons.info_outline,
            iconSize: 22,
            iconColor: theme.colorScheme.primary,
            textStyle: theme.textTheme.titleMedium.semiBold,
          ),
          _TitleInfo(
            t.titleInfo.status,
            mangaData.status,
            Icons.history,
          ),
          _TitleInfo(
            t.titleInfo.source,
            mangaData.sourceName,
            Icons.source,
          ),
          _TitleInfo(
            t.titleInfo.lastUpdateTime,
            timeago.format(
              mangaData.lastUpdate,
              locale: t.$meta.locale.languageCode,
            ),
            Icons.update,
          ),
          const SizedBox(height: 5),
          IconWithText(
            text: t.titleInfo.genres,
            icon: Icons.category_rounded,
            iconSize: 22,
            iconColor: theme.colorScheme.primary,
            textStyle: theme.textTheme.titleMedium.semiBold,
          ),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: mangaData.genres.split(' / ').map((genre) {
              final String value = genre.isEmpty ? 'N/A' : genre;

              return Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: theme.colorScheme.primary.withOpacity(0.2),
                  ),
                ),
                child: Text(value.trim()),
              );
            }).toList(),
          ),
          const SizedBox(height: 5),
          IconWithText(
            text: t.titleInfo.description,
            icon: Icons.description,
            iconSize: 22,
            iconColor: theme.colorScheme.primary,
            textStyle: theme.textTheme.titleMedium.semiBold,
          ),
          ReadMoreText(
            mangaData.description,
            colorClickableText: theme.colorScheme.primary,
            trimExpandedText: t.titleInfo.trimExpanded,
            trimCollapsedText: t.titleInfo.trimCollapsed,
          ),
          const SizedBox(height: 5),
        ],
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

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconWithText(
          text: title,
          icon: icon,
          iconSize: 18,
          iconColor: theme.colorScheme.primary.withValues(alpha: 0.8),
          textStyle: theme.textTheme.titleSmall,
        ),
        Text(value.capitalize)
      ],
    );
  }
}
