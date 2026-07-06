import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:shinga/domain/domain.dart';

part 'title_genre_form_dto.freezed.dart';
part 'title_genre_form_dto.g.dart';

/// DTO for a single genre form option returned by the API.
@freezed
abstract class TitleGenreFormDTO with _$TitleGenreFormDTO {
  /// Creates a [TitleGenreFormDTO] instance.
  const factory TitleGenreFormDTO({
    /// The canonical identifier name of the genre in the system.
    required String name,

    /// The genre name in Russian.
    required String ru,

    /// The genre name in English.
    required String en,
  }) = _TitleGenreFormDTO;

  const TitleGenreFormDTO._();

  /// Creates a [TitleGenreFormDTO] instance from a JSON map.
  factory TitleGenreFormDTO.fromJson(Map<String, dynamic> json) =>
      _$TitleGenreFormDTOFromJson(json);

  /// Converts this DTO to a [TitleGenre] domain model.
  TitleGenre toDomain() => TitleGenre(name: name, ru: ru, en: en);
}

/// DTO wrapping a list of [TitleGenreFormDTO] items returned under the `content` key.
@freezed
abstract class TitleGenreFormsResponseDTO with _$TitleGenreFormsResponseDTO {
  /// Creates a [TitleGenreFormsResponseDTO] instance.
  const factory TitleGenreFormsResponseDTO({
    /// The list of genre form options.
    required List<TitleGenreFormDTO> content,
  }) = _TitleGenreFormsResponseDTO;

  /// Creates a [TitleGenreFormsResponseDTO] instance from a JSON map.
  factory TitleGenreFormsResponseDTO.fromJson(Map<String, dynamic> json) =>
      _$TitleGenreFormsResponseDTOFromJson(json);
}
