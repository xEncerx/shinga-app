import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shinga/domain/domain.dart';
import 'package:shinga/features/features.dart';
import 'package:shinga/i18n/i18n.dart';
import 'package:shinga/i18n/strings.g.dart';
import 'package:ui_kit/ui_kit.dart';

/// Widget to display the genres of a title.
class TitleDetailGenres extends StatelessWidget {
  /// Creates a [TitleDetailGenres] widget.
  const TitleDetailGenres({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocSelector<TitleDetailCubit, TitleDetailState, List<TitleGenre>>(
      selector: (state) => state.data.title.genres,
      builder: (_, genres) {
        if (genres.isEmpty) {
          return const SizedBox.shrink();
        }
        return SaSectionCard.transparent(
          headerLabel: SaText(t.titleDetail.genres),
          headerIcon: const SaIcon(icon: SaIconSource.material(Icons.category)),
          child: SaChipGroup(
            expandButtonLabel: t.titleDetail.common.showMoreChips,
            collapseButtonLabel: t.titleDetail.common.showLessChips,
            maxVisibleChips: 15,
            chips: genres.map((genre) => SaChip(label: genre.i18n)).toList(),
          ),
        );
      },
    );
  }
}
