import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shinga/domain/domain.dart';
import 'package:shinga/features/features.dart';
import 'package:shinga/i18n/i18n.dart';
import 'package:ui_kit/ui_kit.dart';

/// A selector widget for choosing title status in the filter.
class TitleFilterStatusSelector extends StatelessWidget {
  /// Creates a [TitleFilterStatusSelector] widget.
  const TitleFilterStatusSelector({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocSelector<TitleFilterCubit, TitleFilterState, TitleStatus?>(
      selector: (s) => s is TitleFilterLoaded ? s.draft.status : null,
      builder: (_, type) => SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          spacing: AppSpacing.xs,
          children: List.generate(
            TitleStatus.values.length,
            (i) => SaChip(
              label: TitleStatus.values[i].i18n,
              leadingIcon: type == TitleStatus.values[i]
                  ? const SaIconSource.material(Icons.check)
                  : null,
              onTap: () => context.read<TitleFilterCubit>().setStatus(TitleStatus.values[i]),
            ),
          ),
        ),
      ),
    );
  }
}
