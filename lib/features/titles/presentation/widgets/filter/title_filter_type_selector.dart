import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shinga/domain/domain.dart';
import 'package:shinga/features/features.dart';
import 'package:shinga/i18n/i18n.dart';
import 'package:ui_kit/ui_kit.dart';

/// A selector widget for choosing title type in the filter.
class TitleFilterTypeSelector extends StatelessWidget {
  /// Creates a [TitleFilterTypeSelector] widget.
  const TitleFilterTypeSelector({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocSelector<TitleFilterCubit, TitleFilterState, TitleType?>(
      selector: (s) => s is TitleFilterLoaded ? s.draft.type : null,
      builder: (_, type) => SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          spacing: AppSpacing.xs,
          children: List.generate(
            TitleType.values.length,
            (i) => SaChip(
              label: TitleType.values[i].i18n,
              leadingIcon: type == TitleType.values[i]
                  ? const SaIconSource.material(Icons.check)
                  : null,
              onTap: () => context.read<TitleFilterCubit>().setType(TitleType.values[i]),
            ),
          ),
        ),
      ),
    );
  }
}
