import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:intl/intl.dart';

import '../../data/data.dart';
import '../core.dart';

class TileMangaButton extends StatelessWidget {
  const TileMangaButton({
    super.key,
    required this.mangaData,
    this.useCoverCache = true,
  });

  final Manga mangaData;
  final bool useCoverCache;
  static final formatter = NumberFormat.compact();

  @override
  Widget build(BuildContext context) {
    final Color highLightColor = getHighLightColor(
      mangaData.section,
    );
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: () => context.router.push(
        MangaInfoRoute(mangaData: mangaData),
      ),
      child: SizedBox(
        height: 120,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(15),
          child: Row(
            children: [
              MangaPreviewCover(
                width: 90,
                coverUrl: mangaData.cover,
                useCoverCache: useCoverCache,
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
                      color: theme.cardColor,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        spacing: 5,
                        children: [
                          Text(
                            mangaData.name,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.titleMedium,
                          ),
                          IconWithText(
                            text: mangaData.chapters.toString(),
                            icon: HugeIcons.strokeRoundedFile02,
                            iconSize: 24,
                            // isBoldIcon: true,
                          ),
                        ],
                      ),
                    ),
                    Container(
                      height: 30,
                      padding: const EdgeInsets.only(left: 5),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          stops: const [0.2, 0.4, 0.8],
                          colors: [
                            highLightColor.withValues(alpha: 0.2),
                            highLightColor.withValues(alpha: 0.15),
                            highLightColor.withValues(alpha: 0.02),
                          ],
                        ),
                      ),
                      child: Row(
                        spacing: 10,
                        children: [
                          Icon(
                            getSectionIcon(mangaData.section),
                            size: 24,
                            color: highLightColor,
                          ),
                          const Spacer(),
                          IconWithText(
                            text: mangaData.avgRating,
                            icon: Icons.star_rounded,
                            iconSize: 20,
                            textColor: AppTheme.completedHighLight,
                            iconColor: AppTheme.completedHighLight,
                          ),
                          if (mangaData.views > 0) ...[
                            IconWithText(
                              text: formatter.format(mangaData.views),
                              icon: Icons.people,
                              iconSize: 20,
                            ),
                          ],
                          const SizedBox(width: 0)
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
