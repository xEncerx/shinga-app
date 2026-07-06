import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shinga/domain/domain.dart';
import 'package:shinga/features/features.dart';
import 'package:shinga/i18n/i18n.dart';
import 'package:shinga/i18n/strings.g.dart';
import 'package:ui_kit/ui_kit.dart';

/// A selector widget for sorting options in the title filter.
class TitleFilterSortSelector extends StatelessWidget {
  /// Creates a [TitleFilterSortSelector] widget.
  const TitleFilterSortSelector({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocSelector<TitleFilterCubit, TitleFilterState, (TitleSortBy?, TitleSortOrder?)>(
      selector: (s) => s is TitleFilterLoaded ? (s.draft.sortBy, s.draft.sortOrder) : (null, null),
      builder: (_, sorting) {
        return Row(
          spacing: AppSpacing.s,
          children: [
            Expanded(
              child: SaDropdown<TitleSortBy>(
                value: sorting.$1,
                labelText: Translations.of(context).titles.sorting.by.label,
                items: TitleSortBy.values
                    .map((e) => SaDropdownItem(value: e, label: Text(e.i18n)))
                    .toList(),
                onChanged: (v) => _onSortByChanged(context, v),
              ),
            ),
            AnimatedRotation(
              turns: sorting.$2 == TitleSortOrder.ascending ? 0.5 : 0,
              duration: const Duration(milliseconds: 200),
              child: SaIconButton(
                icon: const SaIcon(
                  icon: SaIconSource.huge(
                    HugeIconsStrokeRounded.arrowDown02,
                  ),
                ),
                onPressed: () => _onSortOrderChanged(context),
              ),
            ),
          ],
        );
      },
    );
  }

  void _onSortByChanged(BuildContext context, TitleSortBy? sortBy) {
    context.read<TitleFilterCubit>().setSortBy(sortBy);
  }

  void _onSortOrderChanged(BuildContext context) {
    context.read<TitleFilterCubit>().toggleSortOrder();
  }
}
