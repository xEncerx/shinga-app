import 'package:flutter/material.dart';
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

    return SizedBox(
      height: 160,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(15),
        child: Row(
          children: [
            MangaPreviewCover(
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
                    height: 115,
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 5),
                    color: theme.cardColor,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 5),
                        Text(
                          mangaData.name,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 10),
                        IconWithText(
                          text: "${mangaData.chapters} гл.",
                          icon: Icons.article_outlined,
                        ),
                      ],
                    ),
                  ),
                  Container(
                    height: 45,
                    padding: const EdgeInsets.only(left: 5),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          highLightColor.withValues(alpha: 0.5),
                          highLightColor.withValues(alpha: 0.4),
                          highLightColor.withValues(alpha: 0.15),
                          highLightColor.withValues(alpha: 0.02),
                        ],
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Icon(
                          getSectionIcon(mangaData.section),
                          size: 36,
                          color: highLightColor,
                        ),
                        Row(
                          spacing: 10,
                          children: [
                            IconWithText(
                              text: mangaData.avgRating,
                              icon: Icons.star,
                              iconSize: 24,
                              textColor: Colors.yellow,
                              iconColor: Colors.yellow,
                            ),
                            if (mangaData.views > 0) ...[
                              IconWithText(
                                text: formatter.format(mangaData.views),
                                icon: Icons.people,
                              ),
                            ],
                            const SizedBox(width: 0),
                          ],
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
