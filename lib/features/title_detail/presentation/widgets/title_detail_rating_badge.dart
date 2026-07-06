import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shinga/features/features.dart';
import 'package:ui_kit/ui_kit.dart';

/// A widget that displays the rating badge for a title.
class TitleDetailRatingBadge extends StatelessWidget {
  /// Creates a [TitleDetailRatingBadge] widget.
  const TitleDetailRatingBadge({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocSelector<TitleDetailCubit, TitleDetailState, double>(
      selector: (state) => state.data.title.rating,
      builder: (_, rating) {
        return SaChip(
          label: rating.toStringAsFixed(2),
          leadingIcon: const SaIconSource.material(Icons.star_rounded),
          color: context.appColors.ratingColor,
          textStyle: AppTextStyle.bodyBold.copyWith(
            color: context.appColors.ratingColor.foreground(context),
          ),
        );
      },
    );
  }
}
