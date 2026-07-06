import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shinga/features/features.dart';
import 'package:shinga/i18n/strings.g.dart';
import 'package:ui_kit/ui_kit.dart';

/// Widget to display the authors of a title.
class TitleDetailAuthors extends StatelessWidget {
  /// Creates a [TitleDetailAuthors] widget.
  const TitleDetailAuthors({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocSelector<TitleDetailCubit, TitleDetailState, List<String>>(
      selector: (state) => state.data.title.authors,
      builder: (_, authors) {
        if (authors.isEmpty) {
          return const SizedBox.shrink();
        }
        return SaSectionCard.transparent(
          headerLabel: SaText(t.titleDetail.authors),
          headerIcon: const SaIcon(icon: SaIconSource.huge(HugeIconsStrokeRounded.user)),
          child: SaChipGroup(
            expandButtonLabel: t.titleDetail.common.showMoreChips,
            collapseButtonLabel: t.titleDetail.common.showLessChips,
            chips: authors.map((author) => SaChip(label: author)).toList(),
          ),
        );
      },
    );
  }
}
