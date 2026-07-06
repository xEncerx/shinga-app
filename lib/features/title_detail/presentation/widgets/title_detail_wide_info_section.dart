import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shinga/features/features.dart';
import 'package:shinga/i18n/i18n.dart';
import 'package:shinga/i18n/strings.g.dart';
import 'package:ui_kit/ui_kit.dart';

/// A widget that displays detailed information about a title in a wide layout.
class TitleDetailWideInfoSection extends StatelessWidget {
  /// Creates a [TitleDetailWideInfoSection] widget.
  const TitleDetailWideInfoSection({super.key});

  @override
  Widget build(BuildContext context) {
    final t = Translations.of(context);

    return DottedBorder(
      options: RoundedRectDottedBorderOptions(
        padding: const EdgeInsets.all(1),
        radius: const Radius.circular(AppRadius.l),
        color: context.colors.onSurfaceVariant.withValues(alpha: 0.8),
        dashPattern: [4, 4],
      ),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor.withValues(alpha: 0.8),
          borderRadius: BorderRadius.circular(AppRadius.l),
        ),
        child: BlocBuilder<TitleDetailCubit, TitleDetailState>(
          builder: (_, state) {
            final titleData = state.data.title;
            final releasedAt = titleData.releasedAt;

            return Wrap(
              children: [
                SaStatisticBox(
                  value: titleData.type.i18n,
                  description: t.titleDetail.type,
                  icon: const SaIconSource.huge(HugeIconsStrokeRounded.library),
                  showBorder: false,
                  iconAlignment: SaIconAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                ),
                SaStatisticBox(
                  value: titleData.status.i18n,
                  description: t.titleDetail.status,
                  icon: const SaIconSource.huge(HugeIconsStrokeRounded.status),
                  showBorder: false,
                  iconAlignment: SaIconAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                ),
                SaStatisticBox(
                  value: titleData.chapters.toString(),
                  description: t.titleDetail.chapters,
                  icon: const SaIconSource.huge(HugeIconsStrokeRounded.leftToRightListBullet),
                  showBorder: false,
                  iconAlignment: SaIconAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                ),
                SaStatisticBox(
                  value: numberFormatter.format(titleData.views),
                  description: t.titleDetail.views,
                  icon: const SaIconSource.huge(HugeIconsStrokeRounded.chart01),
                  showBorder: false,
                  iconAlignment: SaIconAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                ),
                SaStatisticBox(
                  value: releasedAt != null ? releasedAt.year.toString() : '--',
                  description: t.titleDetail.year,
                  icon: const SaIconSource.huge(HugeIconsStrokeRounded.clock01),
                  showBorder: false,
                  iconAlignment: SaIconAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
