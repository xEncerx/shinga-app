import 'package:json_annotation/json_annotation.dart';
import 'package:shinga/domain/domain.dart';

/// The sort direction applied to title search results.
@JsonEnum(valueField: 'value')
enum TitleSortOrderDTO {
  /// Sort results from lowest to highest.
  ascending('asc'),

  /// Sort results from highest to lowest.
  descending('desc'),
  ;

  /// Creates a [TitleSortOrderDTO] with the given API [value].
  const TitleSortOrderDTO(this.value);

  /// The raw string value sent to the API.
  final String value;

  @override
  String toString() => value;

  /// Converts this DTO to the [TitleSortOrder] domain entity.
  TitleSortOrder toDomain() => switch (this) {
    TitleSortOrderDTO.ascending => TitleSortOrder.ascending,
    TitleSortOrderDTO.descending => TitleSortOrder.descending,
  };

  /// Converts a [TitleSortOrder] domain entity to this DTO.
  static TitleSortOrderDTO fromDomain(TitleSortOrder sortOrder) => switch (sortOrder) {
    TitleSortOrder.ascending => TitleSortOrderDTO.ascending,
    TitleSortOrder.descending => TitleSortOrderDTO.descending,
  };
}
