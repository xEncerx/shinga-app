import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shinga/domain/domain.dart';
import 'package:shinga/features/features.dart';
import 'package:shinga/i18n/strings.g.dart';
import 'package:ui_kit/ui_kit.dart';

/// The content widget for the title filter screen.
class TitleFilterContent extends StatelessWidget {
  /// Creates a [TitleFilterContent] widget.
  const TitleFilterContent({required this.onApply, super.key});

  /// The callback invoked when the filter is applied.
  final ValueChanged<TitleFilter> onApply;

  @override
  Widget build(BuildContext context) {
    final t = Translations.of(context);

    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.m),
        child: Column(
          spacing: AppSpacing.s,
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SaText(t.titles.common.type, style: AppTextStyle.title),
            const TitleFilterTypeSelector(),
            const SizedBox(height: AppSpacing.xs),
            SaText(t.titles.common.status, style: AppTextStyle.title),
            const TitleFilterStatusSelector(),
            const SizedBox(height: AppSpacing.xs),
            LayoutBuilder(
              builder: (context, constraints) {
                final isWide = constraints.maxWidth >= 400;

                const genreTile = TitleFilterGenresTile();
                const categoryTile = TitleFilterCategoriesTile();

                if (isWide) {
                  return const Row(
                    spacing: AppSpacing.xs,
                    children: [
                      Expanded(child: genreTile),
                      Expanded(child: categoryTile),
                    ],
                  );
                }
                return const Column(
                  spacing: AppSpacing.xs,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [genreTile, categoryTile],
                );
              },
            ),
            const SizedBox(height: AppSpacing.xs),
            SaText(t.titles.common.rating, style: AppTextStyle.title),
            const TitleFilterRatingSelector(),
            SaText(t.titles.common.chapters, style: AppTextStyle.title),
            const TitleFilterChaptersRangeField(),
            const SizedBox(height: AppSpacing.xs),
            SaText(t.titles.sorting.title, style: AppTextStyle.title),
            const TitleFilterSortSelector(),
            const SizedBox(height: AppSpacing.xs),
            Row(
              spacing: AppSpacing.s,
              children: [
                SaTextButton(
                  child: SaText(t.titles.filter.reset),
                  onPressed: () => context.read<TitleFilterCubit>().reset(),
                ),
                Expanded(
                  child: SaPrimaryButton(
                    child: SaText(t.titles.filter.apply),
                    onPressed: () => onApply(
                      (context.read<TitleFilterCubit>().state as TitleFilterLoaded).draft,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
