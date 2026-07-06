import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shinga/domain/domain.dart';
import 'package:shinga/features/features.dart';
import 'package:shinga/i18n/i18n.dart';
import 'package:shinga/i18n/strings.g.dart';
import 'package:ui_kit/ui_kit.dart';

/// A widget that displays detailed information about a title.
class TitleDetailNarrowInfoSection extends StatelessWidget {
  /// Creates a [TitleDetailNarrowInfoSection] widget.
  const TitleDetailNarrowInfoSection({super.key});

  @override
  Widget build(BuildContext context) {
    final t = Translations.of(context);

    return BlocSelector<
      TitleDetailCubit,
      TitleDetailState,
      (TitleType, TitleStatus, int, DateTime?)
    >(
      selector: (state) => (
        state.data.title.type,
        state.data.title.status,
        state.data.title.chapters,
        state.data.title.releasedAt,
      ),
      builder: (_, data) {
        final (type, status, chapters, releasedAt) = data;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: AppSpacing.s,
          children: [
            SaText(
              type.i18n,
              style: AppTextStyle.title.copyWith(
                color: context.appColors.lightGreen,
              ),
            ),
            SaText(
              status.i18n,
              style: AppTextStyle.title,
            ),
            Wrap(
              spacing: AppSpacing.m,
              runSpacing: AppSpacing.s,
              children: [
                SaStatisticBox(
                  value: chapters.toString(),
                  icon: const SaIconSource.huge(HugeIconsStrokeRounded.file02),
                  description: t.titleDetail.chapters,
                ),
                SaStatisticBox(
                  value: releasedAt != null ? releasedAt.year.toString() : 'N/A',
                  icon: const SaIconSource.huge(HugeIconsStrokeRounded.calendar02),
                  description: t.titleDetail.year,
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}
