import 'package:auto_route/auto_route.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';

import '../../data/data.dart';
import '../core.dart';

class CardMangaButton extends StatelessWidget {
  const CardMangaButton({
    super.key,
    required this.mangaData,
    this.width = 140,
    this.height = 220,
    this.useCoverCache = true,
  });

  final Manga mangaData;
  final double width;
  final double height;
  final bool useCoverCache;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: () => context.router.push(
        MangaInfoRoute(mangaData: mangaData),
      ),
      child: SizedBox(
        width: width,
        height: height,
        child: Stack(
          alignment: Alignment.center,
          children: [
            _builtSectionHighLight(mangaData.section),
            Container(
              padding: const EdgeInsets.all(5),
              margin: const EdgeInsets.symmetric(horizontal: 4).copyWith(bottom: 4),
              decoration: BoxDecoration(
                color: theme.cardColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                spacing: 2,
                children: [
                  Flexible(
                    flex: 8,
                    child: MangaPreviewCover(
                      coverUrl: mangaData.cover,
                      width: double.infinity,
                      useCoverCache: useCoverCache,
                    ),
                  ),
                  Flexible(
                    flex: 2,
                    child: Center(
                      child: AutoSizeText(
                        mangaData.name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          height: 1,
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
            Positioned(
              top: 20,
              left: 0,
              child: _buildTextBadge(
                mangaData.avgRating,
                theme,
              ),
            ),
            Positioned(
              top: 40,
              left: 0,
              child: _buildTextBadge(
                mangaData.chapters.toString(),
                theme,
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildTextBadge(String value, ThemeData theme) {
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.primary,
        borderRadius: BorderRadius.circular(5),
      ),
      padding: const EdgeInsets.symmetric(vertical: 1, horizontal: 6),
      child: Text(
        value,
        style: theme.textTheme.bodySmall.semiBold,
      ),
    );
  }

  Widget _builtSectionHighLight(MangaSection section) {
    final Color highLightColor = getHighLightColor(section);

    return Align(
      alignment: Alignment.bottomCenter,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.only(
            bottomLeft: Radius.circular(15),
            bottomRight: Radius.circular(15),
          ),
          gradient: LinearGradient(
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
            colors: [
              highLightColor.withValues(alpha: 0.75),
              highLightColor.withValues(alpha: 0.3),
              highLightColor.withValues(alpha: 0),
            ],
          ),
        ),
        child: SizedBox(
          width: double.infinity,
          height: height / 2,
        ),
      ),
    );
  }
}
