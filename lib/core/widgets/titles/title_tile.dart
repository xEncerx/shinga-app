import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:intl/intl.dart';

import '../../../data/data.dart';
import '../../../features/features.dart';
import '../../../i18n/strings.g.dart';
import '../../core.dart';

/// A button widget that displays title information in a tile format.
class TitleTile extends StatelessWidget {
  /// Creates a [TitleTile] widget.
  ///
  /// - ``titleData``: The [TitleWithUserData] object containing title and user data.
  /// - `useCoverCache`: Whether to use cached cover images.
  const TitleTile({
    super.key,
    required this.titleData,
    this.useCoverCache = true,
  });

  final bool useCoverCache;
  final TitleWithUserData titleData;
  static final formatter = NumberFormat.compact();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final title = titleData.title;
    final userData = titleData.userData;
    final userBookmark = userData?.bookmark ?? BookMarkType.notReading;

    return GestureDetector(
      onTap: () => context.router.push(TitleInfoRoute(titleData: titleData)),
      child: SizedBox(
        height: 120,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(15),
          child: Row(
            children: [
              // Cover
              TitleCover(
                width: 90,
                coverUrl: title.cover.smallUrl?.fullUrl ?? '',
                useCache: useCoverCache,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(15),
                  bottomLeft: Radius.circular(15),
                ),
              ),
              Expanded(
                child: Column(
                  children: [
                    Container(
                      height: 90,
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 5).copyWith(top: 5),
                      color: theme.colorScheme.inversePrimary.withValues(alpha: 0.3),
                      child: Column(
                        spacing: 5,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Title name. Depending on the language, it shows either Russian or English name.
                          BlocBuilder<SettingsCubit, SettingsState>(
                            builder: (context, state) {
                              final locale = state.settings.language;

                              return Text(
                                (locale == AppLocale.ru ? title.nameRu : title.nameEn) ?? '???',
                                maxLines: 2,
                                style: theme.textTheme.titleMedium.ellipsis,
                              );
                            },
                          ),
                          // Chapters count
                          IconWithText(
                            text: title.chapters.toString(),
                            textColor: theme.hintColor,
                            icon: Icon(
                              HugeIcons.strokeRoundedFile02,
                              size: 24,
                              color: theme.hintColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // User bookmark information
                    Container(
                      height: 30,
                      padding: const EdgeInsets.only(left: 5),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          stops: const [0.2, 0.4, 0.8],
                          colors: [
                            userBookmark.color.withValues(alpha: 0.2),
                            userBookmark.color.withValues(alpha: 0.15),
                            userBookmark.color.withValues(alpha: 0.02),
                          ],
                        ),
                      ),
                      child: Row(
                        spacing: 10,
                        children: [
                          // User bookmark icon
                          Icon(
                            userBookmark.icon,
                            size: 24,
                            color: userBookmark.color,
                          ),
                          const Spacer(),
                          // Title rating
                          IconWithText(
                            text: title.rating.toStringAsFixed(1),
                            textColor: BookMarkType.completed.color,
                            icon: Icon(
                              Icons.star_rounded,
                              size: 20,
                              color: BookMarkType.completed.color,
                            ),
                          ),
                          // Title views
                          if (title.views > 0) ...[
                            IconWithText(
                              text: formatter.format(title.views),
                              textColor: theme.hintColor,
                              icon: Icon(
                                Icons.people,
                                size: 20,
                                color: theme.hintColor,
                              ),
                            ),
                          ],
                          const SizedBox(width: 0),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
