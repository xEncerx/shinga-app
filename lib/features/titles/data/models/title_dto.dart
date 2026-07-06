import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:shinga/domain/domain.dart';
import 'package:shinga/features/features.dart';

part 'title_dto.freezed.dart';
part 'title_dto.g.dart';

/// A data model representing a title, as received from the API.
@freezed
abstract class TitleDTO with _$TitleDTO {
  /// Creates a [TitleDTO] instance.
  const factory TitleDTO({
    required int id,
    required int? malId,
    required String? nameRu,
    required String? nameEn,
    required String? descriptionRu,
    required String? descriptionEn,
    required List<String> altNames,
    required TitleTypeDTO type,
    required TitleStatusDTO status,
    required int popularity,
    required int chapters,
    required int views,
    required int volumes,
    required int favorites,
    required double rating,
    required int scoredBy,
    required DateTime? releasedAt,
    required DateTime? endedAt,
    required List<TitleGenreDTO> genres,
    required List<TitleCategoryDTO> categories,
    required List<String> authors,
    required TitleCoverDTO cover,
  }) = _TitleDTO;

  const TitleDTO._();

  /// Creates a [TitleDTO] instance from a JSON map.
  factory TitleDTO.fromJson(Map<String, dynamic> json) => _$TitleDTOFromJson(json);

  /// Converts this [TitleDTO] to a [TitleEntity] domain model.
  TitleEntity toDomain() => TitleEntity(
    id: id,
    malId: malId,
    nameRu: nameRu,
    nameEn: nameEn,
    descriptionRu: descriptionRu,
    descriptionEn: descriptionEn,
    altNames: altNames,
    type: type.toDomain(),
    status: status.toDomain(),
    popularity: popularity,
    chapters: chapters,
    views: views,
    volumes: volumes,
    favorites: favorites,
    rating: rating,
    scoredBy: scoredBy,
    releasedAt: releasedAt,
    endedAt: endedAt,
    genres: genres.map((g) => g.toDomain()).toList(),
    categories: categories.map((c) => c.toDomain()).toList(),
    authors: authors,
    cover: cover.toDomain(),
  );
}
