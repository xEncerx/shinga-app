import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:shinga/domain/domain.dart';

part 'title_cover_dto.freezed.dart';
part 'title_cover_dto.g.dart';

/// A data model representing the cover information of a title, as received from the API.
@freezed
abstract class TitleCoverDTO with _$TitleCoverDTO {
  /// Creates a [TitleCoverDTO] instance.
  const factory TitleCoverDTO({
    required String original,
    required String thumbnail,
  }) = _TitleCoverDTO;

  const TitleCoverDTO._();

  /// Creates a [TitleCoverDTO] instance from a JSON map.
  factory TitleCoverDTO.fromJson(Map<String, dynamic> json) => _$TitleCoverDTOFromJson(json);

  /// Converts this [TitleCoverDTO] to a [TitleCoverEntity] domain model.
  TitleCoverEntity toDomain() => TitleCoverEntity(original: original, thumbnail: thumbnail);
}
