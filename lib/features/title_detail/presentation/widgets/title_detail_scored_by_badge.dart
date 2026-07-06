import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shinga/features/features.dart';
import 'package:ui_kit/ui_kit.dart';

/// A badge widget that displays the number of users who scored the title.
class TitleDetailScoredByBadge extends StatelessWidget {
  /// Creates a [TitleDetailScoredByBadge] widget.
  const TitleDetailScoredByBadge({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocSelector<TitleDetailCubit, TitleDetailState, int>(
      selector: (state) => state.data.title.scoredBy,
      builder: (_, scoredBy) {
        return SaChip(
          label: numberFormatter.format(scoredBy),
          leadingIcon: const SaIconSource.material(Icons.people),
          color: context.appColors.grey,
          textStyle: AppTextStyle.bodyBold.copyWith(
            color: context.appColors.grey.foreground(context),
          ),
        );
      },
    );
  }
}
