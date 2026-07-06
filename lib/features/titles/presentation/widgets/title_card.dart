import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:shinga/core/core.dart';
import 'package:shinga/domain/domain.dart';
import 'package:shinga/features/features.dart';
import 'package:shinga/i18n/i18n.dart';
import 'package:ui_kit/ui_kit.dart';

/// A compact card widget that displays some information about a title.
class TitleCard extends StatelessWidget {
  /// Creates a [TitleCard] widget.
  const TitleCard({
    required this.entity,
    this.useCoverCache = true,
    super.key,
  });

  /// The title entity containing all the data needed to populate the card.
  final TitleWithUserDataEntity entity;

  /// Whether to use cached network images for the cover.
  final bool useCoverCache;

  /// Fixed width for the card.
  static const double defaultWidth = 135;

  /// Fixed height for the card.
  static const double defaultHeight = 220;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colors;
    final bookmarkColor = entity.userData?.bookmark.highlightColor(context.appColors);
    const innerRadius = AppRadius.card - AppSpacing.xs;

    return SizedBox(
      width: defaultWidth,
      height: defaultHeight,
      child: Stack(
        children: [
          // ======== Bookmark highlight =========
          if (bookmarkColor != null) _buildBookmarkHighlight(bookmarkColor),
          // ========= Main content card =========
          Card(
            margin: const EdgeInsets.all(AppSpacing.xs),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(innerRadius),
            ),
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.xs).copyWith(top: AppSpacing.s),
              child: Column(
                spacing: AppSpacing.xs,
                children: [
                  Flexible(
                    flex: 5,
                    child: TitleCover(
                      coverUrl: entity.title.cover.thumbnail.toAbsoluteUrl(),
                      borderRadius: BorderRadius.circular(innerRadius - AppSpacing.xs),
                      useCache: useCoverCache,
                    ),
                  ),
                  Flexible(
                    child: Center(
                      child: SaText(
                        entity.title.name,
                        maxLines: 2,
                        textAlign: TextAlign.center,
                        style: AppTextStyle.body.copyWith(
                          height: 0.9,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // ========= Rating badge =========
          _buildStatisticBadge(
            colorScheme: colorScheme,
            topPosition: 25,
            data: entity.title.rating.toStringAsFixed(1),
          ),
          // ========= Chapters badge =========
          if (entity.title.chapters > 0)
            _buildStatisticBadge(
              colorScheme: colorScheme,
              topPosition: 45,
              data: entity.title.chapters.toString(),
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

  /// Builds a small pill-shaped badge displaying [data] at the given [topPosition].
  Widget _buildStatisticBadge({
    required ColorScheme colorScheme,
    required double topPosition,
    required String data,
  }) {
    return Positioned(
      left: 0,
      top: topPosition,
      child: Container(
        constraints: const BoxConstraints(minWidth: 20),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.xs,
          vertical: AppSpacing.xxxs,
        ),
        decoration: BoxDecoration(
          color: colorScheme.primary,
          borderRadius: BorderRadius.circular(AppRadius.s),
        ),
        child: SaText(
          data,
          textAlign: TextAlign.center,
          style: AppTextStyle.captionS.copyWith(
            color: colorScheme.onPrimary,
          ),
        ),
      ),
    );
  }

  /// Builds the gradient bookmark highlight shown at the bottom of the card.
  Widget _buildBookmarkHighlight(Color highlightColor) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: SizedBox(
        width: double.infinity,
        height: defaultHeight / 1.5,
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(AppRadius.card),
              bottomRight: Radius.circular(AppRadius.card),
            ),
            gradient: LinearGradient(
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
              colors: [
                highlightColor.withValues(alpha: 0.8),
                highlightColor.withValues(alpha: 0.5),
                highlightColor.withValues(alpha: 0.2),
                highlightColor.withValues(alpha: 0),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _onTap(BuildContext context) => context.router.push(TitleDetailRoute(titleData: entity));
}
