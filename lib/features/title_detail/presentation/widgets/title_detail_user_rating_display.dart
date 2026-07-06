import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shinga/features/features.dart';
import 'package:shinga/i18n/strings.g.dart';
import 'package:ui_kit/ui_kit.dart';

/// Displays the user's rating for a title.
class TitleDetailUserRatingDisplay extends StatelessWidget {
  /// Creates a [TitleDetailUserRatingDisplay] widget.
  const TitleDetailUserRatingDisplay({super.key});

  @override
  Widget build(BuildContext context) {
    final t = Translations.of(context);
    final ratingColors = context.appColors.ratingColor;

    return BlocSelector<TitleDetailCubit, TitleDetailState, double?>(
      selector: (state) => state.data.userData?.rating,
      builder: (_, userRating) {
        return userRating != null && userRating > 0
            ? Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SaIconText(
                    label: SaText(t.titleDetail.rating.my, style: AppTextStyle.bodyBold),
                    icon: const SaIcon(
                      icon: SaIconSource.huge(HugeIconsStrokeRounded.starCircle),
                    ),
                  ),
                  SaIconText(
                    label: SaText(
                      userRating.toStringAsFixed(0),
                      style: AppTextStyle.bodyBold.copyWith(
                        color: ratingColors,
                      ),
                    ),
                    icon: SaIcon(
                      icon: const SaIconSource.material(Icons.star),
                      color: ratingColors,
                      size: 20,
                    ),
                  ),
                ],
              )
            : const SizedBox.shrink();
      },
    );
  }
}
