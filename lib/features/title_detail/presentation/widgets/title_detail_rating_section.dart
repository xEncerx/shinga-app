import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shinga/features/features.dart';
import 'package:shinga/i18n/strings.g.dart';
import 'package:ui_kit/ui_kit.dart';

/// Widget for displaying the rating section of the title.
class TitleDetailRatingSection extends StatelessWidget {
  /// Creates a [TitleDetailRatingSection] widget.
  const TitleDetailRatingSection({super.key});

  @override
  Widget build(BuildContext context) {
    final t = Translations.of(context);

    return BlocBuilder<TitleDetailCubit, TitleDetailState>(
      builder: (_, state) {
        final titleData = state.data.title;
        final (rating, scoredBy, userRating, isRatingLoading) = (
          titleData.rating.toStringAsFixed(1),
          numberFormatter.format(titleData.scoredBy),
          state.data.userData?.rating.toStringAsFixed(0),
          state.isFieldLoading(TitleDetailField.rating),
        );

        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            SaText(
              rating,
              style: AppTextStyle.titleL.copyWith(color: context.appColors.ratingColor),
            ),
            SaText(
              t.titleDetail.rating.totalScores(scores: scoredBy),
              style: AppTextStyle.body,
            ),
            const SizedBox(height: AppSpacing.s),
            SaPrimaryButton(
              height: 28,
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s),
              isLoading: isRatingLoading,
              onPressed: userRating != null
                  ? () async => _showRatingDialog(context, double.parse(userRating))
                  : null,
              child: SaText(
                userRating != null && userRating != '0'
                    ? t.titleDetail.rating.userScore(score: userRating)
                    : t.titleDetail.rating.scoreButton,
              ),
            ),
          ],
        );
      },
    );
  }
}

Future<void> _showRatingDialog(BuildContext context, double currentRating) async {
  final t = Translations.of(context);

  await showDialog<void>(
    context: context,
    builder: (_) => SaAppDialog(
      title: Center(child: SaText(t.titleDetail.rating.dialogTitle)),
      content: Column(
        spacing: AppSpacing.m,
        mainAxisSize: MainAxisSize.min,
        children: [
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Row(
              spacing: AppSpacing.s,
              children: List.generate(
                11,
                (i) => SaFloatingActionButton(
                  size: 42,
                  onPressed: () async {
                    context.router.pop();
                    await context.read<TitleDetailCubit>().changeRating(i.toDouble());
                  },
                  backgroundColor: i <= currentRating
                      ? context.appColors.ratingColor
                      : context.colors.surfaceContainerHighest,
                  child: SaText(i.toString(), style: AppTextStyle.bodyBold),
                ),
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SaText(
                t.titleDetail.rating.veryBad,
                style: AppTextStyle.titleS,
              ),
              SaText(
                t.titleDetail.rating.excellent,
                style: AppTextStyle.titleS,
              ),
            ],
          ),
        ],
      ),
    ),
  );
}
