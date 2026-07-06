import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shinga/domain/domain.dart';
import 'package:shinga/features/features.dart';
import 'package:shinga/i18n/i18n.dart';
import 'package:shinga/i18n/strings.g.dart';
import 'package:ui_kit/ui_kit.dart';

/// A tile widget for selecting title genres in the filter.
class TitleFilterGenresTile extends StatelessWidget {
  /// Creates a [TitleFilterGenresTile] widget.
  const TitleFilterGenresTile({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocSelector<TitleFilterCubit, TitleFilterState, (List<TitleGenre>, List<TitleGenre>?)>(
      selector: (s) => s is TitleFilterLoaded ? (s.allGenres, s.draft.genres) : ([], null),
      builder: (_, genreData) {
        final t = Translations.of(context);
        final allGenres = genreData.$1;
        final selectedGenres = genreData.$2;

        return SaListTile(
          title: SaText(t.titles.filter.genres.title),
          leading: const SaIcon(
            icon: SaIconSource.huge(HugeIconsStrokeRounded.paintBoard),
          ),
          trailing: const SaIcon(
            icon: SaIconSource.huge(HugeIconsStrokeRounded.arrowRight01),
          ),
          subtitle: SaText(
            t.titles.filter.selected(count: selectedGenres?.length ?? 0),
          ),
          onTap: () async {
            final result = await showDialog<List<TitleGenre>?>(
              context: context,
              builder: (_) => SaSearchableMultiSelectDialog<TitleGenre>(
                items: allGenres,
                title: t.titles.filter.genres.title,
                searchHint: t.titles.filter.genres.searchHint,
                applyText: t.titles.filter.apply,
                resetText: t.titles.filter.reset,
                itemLabelBuilder: (genre) => genre.i18n,
                initialSelectedItems: selectedGenres ?? [],
                searchFunction: (query) {
                  final q = query.toLowerCase();
                  return allGenres.where(
                    (v) => v.ru.toLowerCase().contains(q) || v.en.toLowerCase().contains(q),
                  );
                },
              ),
            );
            if (context.mounted && result != null) {
              context.read<TitleFilterCubit>().setGenres(result);
            }
          },
        );
      },
    );
  }
}
