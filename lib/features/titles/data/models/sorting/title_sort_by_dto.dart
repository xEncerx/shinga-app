import 'package:json_annotation/json_annotation.dart';
import 'package:shinga/domain/domain.dart';

/// The field by which title search results are sorted.
@JsonEnum(valueField: 'value')
enum TitleSortByDTO {
  /// Sort by internal identifier.
  id('id'),

  /// Sort by user rating.
  rating('rating'),

  /// Sort by popularity score.
  popularity('popularity'),

  /// Sort by number of chapters.
  chapters('chapters'),

  /// Sort by view count.
  views('views'),

  /// Sort by number of times added to favorites.
  favorites('favorites'),

  /// Sort by original release date.
  releaseDate('released_at'),

  /// Sort by the date of the latest update.
  updateDate('updated_at'),
  ;

  /// Creates a [TitleSortByDTO] with the given API [value].
  const TitleSortByDTO(this.value);

  /// The raw string value sent to the API.
  final String value;

  @override
  String toString() => value;

  /// Converts this DTO to the [TitleSortByDTO] domain entity.
  TitleSortBy toDomain() => switch (this) {
    TitleSortByDTO.id => TitleSortBy.id,
    TitleSortByDTO.rating => TitleSortBy.rating,
    TitleSortByDTO.popularity => TitleSortBy.popularity,
    TitleSortByDTO.chapters => TitleSortBy.chapters,
    TitleSortByDTO.views => TitleSortBy.views,
    TitleSortByDTO.favorites => TitleSortBy.favorites,
    TitleSortByDTO.releaseDate => TitleSortBy.releaseDate,
    TitleSortByDTO.updateDate => TitleSortBy.updateDate,
  };

  /// Converts a [TitleSortBy] domain entity to this DTO.
  static TitleSortByDTO fromDomain(TitleSortBy sortBy) => switch (sortBy) {
    TitleSortBy.id => TitleSortByDTO.id,
    TitleSortBy.rating => TitleSortByDTO.rating,
    TitleSortBy.popularity => TitleSortByDTO.popularity,
    TitleSortBy.chapters => TitleSortByDTO.chapters,
    TitleSortBy.views => TitleSortByDTO.views,
    TitleSortBy.favorites => TitleSortByDTO.favorites,
    TitleSortBy.releaseDate => TitleSortByDTO.releaseDate,
    TitleSortBy.updateDate => TitleSortByDTO.updateDate,
  };
}
