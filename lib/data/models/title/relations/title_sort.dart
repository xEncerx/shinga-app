import '../../../../i18n/strings.g.dart';

enum TitleSortBy {
  rating('rating'),
  popularity('popularity'),
  favorites('favorites'),
  chapters('chapters'),
  views('views'),
  userUpdatedAt('user_updated_at');

  const TitleSortBy(this.value);

  final String value;

  String get i18n {
    switch (this) {
      case TitleSortBy.rating:
        return t.searching.sorting.rating;
      case TitleSortBy.popularity:
        return t.searching.sorting.popularity;
      case TitleSortBy.favorites:
        return t.searching.sorting.favorites;
      case TitleSortBy.chapters:
        return t.searching.sorting.chapters;
      case TitleSortBy.views:
        return t.searching.sorting.views;
      case TitleSortBy.userUpdatedAt:
        return t.searching.sorting.userUpdatedAt;
    }
  }
}

enum TitleSortOrder {
  asc,
  desc;

  String get i18n {
    switch (this) {
      case TitleSortOrder.asc:
        return t.searching.sorting.ascending;
      case TitleSortOrder.desc:
        return t.searching.sorting.descending;
    }
  }
}
