import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:shinga/domain/domain.dart';

part 'title_pagination_detail_dto.freezed.dart';
part 'title_pagination_detail_dto.g.dart';

/// DTO for paginated content metadata of a title list response.
@freezed
abstract class TitlePaginationContentMetadataDTO with _$TitlePaginationContentMetadataDTO {
  /// Creates a [TitlePaginationContentMetadataDTO] instance.
  const factory TitlePaginationContentMetadataDTO({
    /// The number of items in the current page.
    required int count,

    /// The total number of items across all pages.
    required int total,

    /// The maximum number of items returned per page.
    required int perPage,
  }) = _TitlePaginationContentMetadataDTO;

  const TitlePaginationContentMetadataDTO._();

  /// Creates a [TitlePaginationContentMetadataDTO] instance from a JSON map.
  factory TitlePaginationContentMetadataDTO.fromJson(Map<String, dynamic> json) =>
      _$TitlePaginationContentMetadataDTOFromJson(json);
}

/// DTO for pagination details of a title list response.
@freezed
abstract class TitlePaginationDetailDTO with _$TitlePaginationDetailDTO {
  /// Creates a [TitlePaginationDetailDTO] instance.
  const factory TitlePaginationDetailDTO({
    /// The index of the last visible page.
    required int lastVisiblePage,

    /// Whether there is a subsequent page available.
    required bool hasNextPage,

    /// The index of the currently requested page.
    required int currentPage,

    /// Content metadata for the current page.
    required TitlePaginationContentMetadataDTO items,
  }) = _TitlePaginationDetailDTO;

  const TitlePaginationDetailDTO._();

  /// Creates a [TitlePaginationDetailDTO] instance from a JSON map.
  factory TitlePaginationDetailDTO.fromJson(Map<String, dynamic> json) =>
      _$TitlePaginationDetailDTOFromJson(json);

  /// Converts this DTO to a [PaginationDetail] domain entity.
  PaginationDetail toDomain() => PaginationDetail(
    lastVisiblePage: lastVisiblePage,
    hasNextPage: hasNextPage,
    currentPage: currentPage,
    metadata: PaginatedContentMetadata(
      count: items.count,
      total: items.total,
      perPage: items.perPage,
    ),
  );
}
