import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:shinga/domain/domain.dart';

part 'title_filter.freezed.dart';

/// An immutable value object representing filter parameters for title searches.
@freezed
abstract class TitleFilter with _$TitleFilter {
  /// Creates a [TitleFilter] instance.
  const factory TitleFilter({
    /// The type of titles to filter by.
    TitleType? type,

    /// The publication status of titles to filter by.
    TitleStatus? status,

    /// The list of genres to filter titles by.
    List<TitleGenre>? genres,

    /// The list of categories to filter titles by.
    List<TitleCategory>? categories,

    /// The minimum rating threshold for filtering titles.
    int? minRating,

    /// The maximum rating threshold for filtering titles.
    int? maxRating,

    /// The minimum number of chapters for filtering titles.
    int? minChapters,

    /// The maximum number of chapters for filtering titles.
    int? maxChapters,

    /// The field to sort titles by.
    TitleSortBy? sortBy,

    /// The order to sort titles in.
    TitleSortOrder? sortOrder,
  }) = _TitleFilter;

  /// An empty filter with no constraints applied.
  static const empty = TitleFilter();

  /// A filter preset for user favorites, sorting by update date in descending order.
  static const userFavorites = TitleFilter(
    sortBy: TitleSortBy.updateDate,
    sortOrder: TitleSortOrder.descending,
  );
}
