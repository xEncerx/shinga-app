/// Enumeration representing the different criteria by which titles can be sorted.
enum TitleSortBy {
  /// Sort by internal identifier.
  id,

  /// Sort by user rating.
  rating,

  /// Sort by popularity score.
  popularity,

  /// Sort by number of chapters.
  chapters,

  /// Sort by view count.
  views,

  /// Sort by number of times added to favorites.
  favorites,

  /// Sort by original release date.
  releaseDate,

  /// Sort by the date of the latest update.
  updateDate,
}
