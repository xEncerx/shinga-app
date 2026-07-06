import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shinga/domain/domain.dart';
import 'package:shinga/features/features.dart';
import 'package:shinga/i18n/i18n.dart';
import 'package:shinga/i18n/strings.g.dart';
import 'package:ui_kit/ui_kit.dart';

/// A tile widget for selecting title categories in the filter.
class TitleFilterCategoriesTile extends StatelessWidget {
  /// Creates a [TitleFilterCategoriesTile] widget.
  const TitleFilterCategoriesTile({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocSelector<
      TitleFilterCubit,
      TitleFilterState,
      (List<TitleCategory>, List<TitleCategory>?)
    >(
      selector: (s) => s is TitleFilterLoaded ? (s.allCategories, s.draft.categories) : ([], null),
      builder: (_, categoryData) {
        final t = Translations.of(context);
        final allCategories = categoryData.$1;
        final selectedCategories = categoryData.$2;

        return SaListTile(
          title: SaText(t.titles.filter.categories.title),
          leading: const SaIcon(
            icon: SaIconSource.huge(HugeIconsStrokeRounded.checkList),
          ),
          trailing: const SaIcon(
            icon: SaIconSource.huge(HugeIconsStrokeRounded.arrowRight01),
          ),
          subtitle: SaText(
            t.titles.filter.selected(count: selectedCategories?.length ?? 0),
          ),
          onTap: () async {
            final result = await showDialog<List<TitleCategory>?>(
              context: context,
              builder: (_) => SaSearchableMultiSelectDialog<TitleCategory>(
                items: allCategories,
                title: t.titles.filter.categories.title,
                searchHint: t.titles.filter.categories.searchHint,
                applyText: t.titles.filter.apply,
                resetText: t.titles.filter.reset,
                itemLabelBuilder: (category) => category.i18n,
                searchFunction: (query) {
                  final q = query.toLowerCase();
                  return allCategories.where(
                    (v) => v.ru.toLowerCase().contains(q) || v.en.toLowerCase().contains(q),
                  );
                },
                initialSelectedItems: selectedCategories ?? [],
              ),
            );
            if (context.mounted && result != null) {
              context.read<TitleFilterCubit>().setCategories(result);
            }
          },
        );
      },
    );
  }
}
