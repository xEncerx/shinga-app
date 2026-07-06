import 'package:shinga/domain/domain.dart';
import 'package:shinga/i18n/strings.g.dart';

/// Extension on [TitleSortBy] to provide internationalized strings.
extension TitleSortByI18n on TitleSortBy {
  /// Returns the internationalized string corresponding to this [TitleSortBy].
  String get i18n => switch (this) {
    TitleSortBy.id => t.titles.sorting.by.id,
    TitleSortBy.rating => t.titles.sorting.by.rating,
    TitleSortBy.popularity => t.titles.sorting.by.popularity,
    TitleSortBy.chapters => t.titles.sorting.by.chapters,
    TitleSortBy.views => t.titles.sorting.by.views,
    TitleSortBy.favorites => t.titles.sorting.by.favorites,
    TitleSortBy.releaseDate => t.titles.sorting.by.releaseDate,
    TitleSortBy.updateDate => t.titles.sorting.by.updateDate,
  };
}
