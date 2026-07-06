import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shinga/core/core.dart';
import 'package:shinga/domain/domain.dart';
import 'package:shinga/features/features.dart';
import 'package:shinga/i18n/i18n.dart';
import 'package:ui_kit/ui_kit.dart';

/// A widget that displays the title's cover image in the detail page.
class TitleDetailPreviewCover extends StatelessWidget {
  /// Creates a [TitleDetailPreviewCover] instance.
  const TitleDetailPreviewCover({
    this.height = 220,
    this.showBookmark = true,
    super.key,
  });

  /// The height of the cover image.
  final double height;

  /// Whether to show the bookmark highlight.
  final bool showBookmark;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: AspectRatio(
        aspectRatio: 2 / 3,
        child: BlocSelector<TitleDetailCubit, TitleDetailState, (String, Bookmark?)>(
          selector: (state) => (
            state.data.title.cover.original.toAbsoluteUrl(),
            state.data.userData?.bookmark,
          ),
          builder: (_, data) {
            final (coverUrl, bookmark) = (data.$1, data.$2);
            final bookmarkColor = bookmark?.highlightColor(context.appColors);
            final hasEffectiveBookmark = bookmark != null && bookmarkColor != null;

            return Stack(
              children: [
                if (showBookmark && hasEffectiveBookmark)
                  _buildBookmarkHighlight(context, bookmarkColor),
                Column(
                  children: [
                    Flexible(
                      flex: 7,
                      child: TitleCover(coverUrl: coverUrl),
                    ),
                    if (showBookmark && hasEffectiveBookmark)
                      Flexible(
                        child: Center(
                          child: SaText(
                            bookmark.i18n,
                            style: AppTextStyle.titleM.copyWith(
                              color: bookmarkColor.foreground(context),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  /// Builds the gradient bookmark highlight shown at the bottom of the card.
  Widget _buildBookmarkHighlight(BuildContext context, Color highlightColor) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
        child: SizedBox(
          height: height / 1.5,
          width: double.infinity,
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
                  highlightColor.withValues(alpha: 1),
                  highlightColor.withValues(alpha: 0.8),
                  highlightColor.withValues(alpha: 0),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
