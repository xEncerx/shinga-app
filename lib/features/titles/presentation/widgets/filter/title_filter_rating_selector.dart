import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shinga/features/features.dart';
import 'package:ui_kit/ui_kit.dart';

/// A selector widget for choosing rating range in the title filter.
class TitleFilterRatingSelector extends StatelessWidget {
  /// Creates a [TitleFilterRatingSelector] widget.
  const TitleFilterRatingSelector({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocSelector<TitleFilterCubit, TitleFilterState, (int?, int?)>(
      selector: (s) =>
          s is TitleFilterLoaded ? (s.draft.minRating, s.draft.maxRating) : (null, null),
      builder: (_, ratings) => Row(
        children: [
          SizedBox(
            width: 20,
            child: SaText(
              ratings.$1?.toString() ?? '1',
              style: AppTextStyle.titleS,
            ),
          ),
          Expanded(
            child: RangeSlider(
              values: RangeValues(
                ratings.$1?.toDouble() ?? 1,
                ratings.$2?.toDouble() ?? 10,
              ),
              min: 1,
              max: 10,
              divisions: 9,
              onChanged: (v) => _onRatingChanged(context, v),
            ),
          ),
          SizedBox(
            width: 20,
            child: SaText(
              ratings.$2?.toString() ?? '10',
              style: AppTextStyle.titleS,
            ),
          ),
        ],
      ),
    );
  }

  void _onRatingChanged(BuildContext context, RangeValues values) {
    context.read<TitleFilterCubit>().setRating(
      values.start.round(),
      values.end.round(),
    );
  }
}
