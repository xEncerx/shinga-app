import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:shinga/domain/domain.dart';
import 'package:shinga/features/features.dart';

part 'title_search_data_dto.freezed.dart';
part 'title_search_data_dto.g.dart';

/// DTO representing a paginated title search result.
@freezed
abstract class TitleSearchDataDTO with _$TitleSearchDataDTO {
  /// Creates a [TitleSearchDataDTO] instance.
  const factory TitleSearchDataDTO({
    /// Pagination details for the current result page.
    required TitlePaginationDetailDTO pagination,

    /// The list of titles with user-specific data returned by the search.
    required List<TitleWithUserDataDTO> content,
  }) = _TitleSearchDataDTO;

  const TitleSearchDataDTO._();

  /// Creates a [TitleSearchDataDTO] instance from a JSON map.
  factory TitleSearchDataDTO.fromJson(Map<String, dynamic> json) =>
      _$TitleSearchDataDTOFromJson(json);

  /// Converts this DTO to a [TitleSearchData] domain entity.
  TitleSearchData toDomain() => TitleSearchData(
    pagination: pagination.toDomain(),
    content: content.map((dto) => dto.toDomain()).toList(),
  );
}
