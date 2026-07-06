import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:shinga/core/core.dart';
import 'package:shinga/domain/domain.dart';
import 'package:shinga/features/features.dart';
import 'package:shinga/i18n/i18n.dart';
import 'package:ui_kit/ui_kit.dart';

/// A horizontal list tile that displays some information about a title.
class TitleTile extends StatelessWidget {
  /// Creates a [TitleTile] widget.
  const TitleTile({
    required this.entity,
    this.useCoverCache = true,
    super.key,
  });

  /// The title entity containing all the data needed to populate the card.
  final TitleWithUserDataEntity entity;

  /// Whether to use cached network images for the cover.
  final bool useCoverCache;

  /// Fixed height for the tile.
  static const double defaultHeight = 140;

  /// The maximum width of the tile to prevent it from stretching too much on larger screens.
  static const double maxWidth = 600;

  /// The width of the cover image, calculated based on the fixed height and aspect ratio.
  static const double _imageWidth = defaultHeight * (2 / 3);

  /// The height of the bookmark highlight as a fraction of the total height.
  static const double _bookmarkHighlightHeight = defaultHeight * 0.25;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final appColors = context.appColors;
    final highlightColor = entity.userData?.bookmark.highlightColor(appColors);

    return ConstrainedBox(
      constraints: const BoxConstraints(
        maxWidth: maxWidth,
        minHeight: defaultHeight,
        maxHeight: defaultHeight,
      ),
      child: Stack(
        alignment: AlignmentDirectional.bottomCenter,
        children: [
          // ======== Bookmark highlight =========
          Material(
            elevation: 5,
            borderRadius: BorderRadius.circular(AppRadius.card),
            child: Container(
              height: defaultHeight,
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.m,
              ),
              margin: const EdgeInsets.only(
                top: defaultHeight - _bookmarkHighlightHeight,
                left: _imageWidth,
              ),
              decoration: BoxDecoration(
                gradient: highlightColor != null
                    ? LinearGradient(
                        stops: const [0.2, 0.4, 0.8],
                        colors: [
                          highlightColor.withValues(alpha: 0.3),
                          highlightColor.withValues(alpha: 0.2),
                          highlightColor.withValues(alpha: 0.02),
                        ],
                      )
                    : null,
              ),
              child: IconTheme(
                data: const IconThemeData(size: 20),
                child: Row(
                  spacing: AppSpacing.m,
                  children: [
                    if (highlightColor != null)
                      SaIcon(
                        icon: entity.userData!.bookmark.icon,
                        color: highlightColor,
                      ),
                    const Spacer(),
                    SaIconText(
                      spacing: AppSpacing.xs,
                      icon: SaIcon(
                        icon: const SaIconSource.material(Icons.star_rounded),
                        color: appColors.ratingColor,
                      ),
                      label: SaText(
                        entity.title.rating.toStringAsFixed(1),
                        style: AppTextStyle.bodyBold.copyWith(
                          color: appColors.ratingColor,
                        ),
                      ),
                    ),
                    SaIconText(
                      spacing: AppSpacing.xs,
                      icon: SaIcon(
                        icon: const SaIconSource.material(Icons.person),
                        color: theme.hintColor,
                      ),
                      label: SaText(
                        numberFormatter.format(entity.title.views),
                        style: AppTextStyle.bodyL.copyWith(
                          color: theme.hintColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // ======== Cover + name =========
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TitleCover(
                coverUrl: entity.title.cover.thumbnail.toAbsoluteUrl(),
                useCache: useCoverCache,
                width: defaultHeight * (2 / 3),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(AppRadius.card),
                  bottomLeft: Radius.circular(AppRadius.card),
                ),
              ),
              Expanded(
                child: Material(
                  elevation: 5,
                  borderRadius: const BorderRadius.horizontal(
                    right: Radius.circular(AppRadius.card),
                  ),
                  child: Container(
                    height: defaultHeight - _bookmarkHighlightHeight,
                    padding: const EdgeInsets.all(AppSpacing.s),
                    decoration: BoxDecoration(
                      color: theme.cardColor,
                      borderRadius: const BorderRadius.horizontal(
                        right: Radius.circular(AppRadius.card),
                      ),
                    ),
                    child: Column(
                      spacing: AppSpacing.s,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SaText(
                          entity.title.name,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyle.titleM,
                        ),
                        SaIconText(
                          spacing: AppSpacing.xs,
                          label: SaText(
                            entity.title.chapters.toString(),
                            style: AppTextStyle.bodyL.copyWith(
                              color: theme.hintColor,
                            ),
                          ),
                          icon: SaIcon(
                            icon: const SaIconSource.huge(HugeIconsStrokeRounded.file02),
                            color: theme.hintColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          // ========= Clickable area =========
          Positioned.fill(
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => _onTap(context),
                mouseCursor: SystemMouseCursors.click,
                borderRadius: BorderRadius.circular(AppRadius.card),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _onTap(BuildContext context) => context.router.push(TitleDetailRoute(titleData: entity));
}
