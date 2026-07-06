import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shinga/domain/domain.dart';
import 'package:shinga/features/features.dart';
import 'package:shinga/i18n/i18n.dart';
import 'package:shinga/i18n/strings.g.dart';
import 'package:ui_kit/ui_kit.dart';

/// Widget that displays the categories of a title.
class TitleDetailCategories extends StatelessWidget {
  /// Creates a [TitleDetailCategories] widget.
  const TitleDetailCategories({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocSelector<TitleDetailCubit, TitleDetailState, List<TitleCategory>>(
      selector: (state) => state.data.title.categories,
      builder: (_, categories) {
        if (categories.isEmpty) {
          return const SizedBox.shrink();
        }
        return SaSectionCard.transparent(
          headerLabel: SaText(t.titleDetail.categories),
          headerIcon: const SaIcon(
            icon: SaIconSource.huge(HugeIconsStrokeRounded.maskTheater02),
          ),
          child: SaChipGroup(
            expandButtonLabel: t.titleDetail.common.showMoreChips,
            collapseButtonLabel: t.titleDetail.common.showLessChips,
            maxVisibleChips: 15,
            chips: categories.map((category) => SaChip(label: category.i18n)).toList(),
          ),
        );
      },
    );
  }
}
