import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/data.dart';
import '../../../features/features.dart';
import '../../../i18n/strings.g.dart';
import '../../core.dart';

/// A button widget that displays title information in a card format.
class TitleCard extends StatelessWidget {
  /// Creates a [TitleCard] widget.
  const TitleCard({
    super.key,
    required this.titleData,
    this.useCoverCache = true,
  });

  /// The [TitleWithUserData] object containing title and user data.
  final TitleWithUserData titleData;
  /// Whether to use cached cover images.
  final bool useCoverCache;

  /// Fixed dimensions for the card.
  static const double width = 135;
  /// Fixed height for the card.
  static const double height = 220;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final userData = titleData.userData;
    final title = titleData.title;

    return GestureDetector(
      onTap: () => context.router.push(TitleInfoRoute(titleData: titleData)),
      child: SizedBox(
        width: width,
        height: height,
        child: Stack(
          alignment: Alignment.center,
          children: [
            _builtSectionHighLight(userData?.bookmark ?? BookMarkType.notReading),
            Container(
              padding: const EdgeInsets.all(5),
              margin: const EdgeInsets.symmetric(horizontal: 4).copyWith(bottom: 4),
              decoration: BoxDecoration(
                color: theme.colorScheme.inversePrimary,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                spacing: 2,
                children: [
                  Flexible(
                    flex: 8,
                    child: TitleCover(
                      coverUrl: title.cover.smallUrl?.fullUrl ?? '',
                      width: double.infinity,
                      useCache: useCoverCache,
                    ),
                  ),
                  // Title name. Depending on the language, it shows either Russian or English name.
                  Flexible(
                    flex: 2,
                    child: Center(
                      child: BlocBuilder<SettingsCubit, SettingsState>(
                        builder: (context, state) {
                          final locale = state.settings.language;

                          return Text(
                            (locale == AppLocale.ru ? title.nameRu : title.nameEn) ?? '???',
                            maxLines: 2,
                            textAlign: TextAlign.center,
                            style: theme.textTheme.bodyMedium.height(1).ellipsis,
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Display rating badge
            Positioned(
              top: 20,
              left: 0,
              child: _buildTextBadge(
                title.rating.toStringAsFixed(1),
                theme,
              ),
            ),
            // Display chapter count badge
            Positioned(
              top: 40,
              left: 0,
              child: _buildTextBadge(
                title.chapters.toString(),
                theme,
              ),
            ),
          ],
        ),
      ),
    ).clickable;
  }

  /// Creates a text badge with colored background to display information.
  ///
  /// Used for showing rating or chapter count.
  Widget _buildTextBadge(String value, ThemeData theme) {
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.primary,
        borderRadius: BorderRadius.circular(5),
      ),
      padding: const EdgeInsets.symmetric(vertical: 1, horizontal: 6),
      child: Text(
        value,
        style: theme.textTheme.bodySmall.semiBold.withColor(theme.colorScheme.onPrimary),
      ),
    );
  }

  /// Creates a colored highlight effect based on title bookmark.
  ///
  /// Displays a gradient at the bottom of the card to visually
  /// indicate the title's bookmark.
  Widget _builtSectionHighLight(BookMarkType bookmark) {
    final Color highLightColor = bookmark.color;

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
        child: const SizedBox(
          width: double.infinity,
          height: height / 2,
        ),
      ),
    );
  }
}
