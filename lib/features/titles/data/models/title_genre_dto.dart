import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:shinga/domain/domain.dart';

part 'title_genre_dto.freezed.dart';
part 'title_genre_dto.g.dart';

/// A data model representing a genre of a title, as received from the API.
@freezed
abstract class TitleGenreDTO with _$TitleGenreDTO {
  /// Creates a [TitleGenreDTO] instance.
  const factory TitleGenreDTO({
    required String name,
    required String ru,
    required String en,
  }) = _TitleGenreDTO;

  const TitleGenreDTO._();

  /// Creates a [TitleGenreDTO] instance from a JSON map.
  factory TitleGenreDTO.fromJson(Map<String, dynamic> json) => _$TitleGenreDTOFromJson(json);

  /// Creates a [TitleGenreDTO] from a [TitleGenre] domain model.
  factory TitleGenreDTO.fromDomain(TitleGenre genre) => TitleGenreDTO(
    name: genre.name,
    ru: genre.ru,
    en: genre.en,
  );

  /// Converts this [TitleGenreDTO] to a [TitleGenre] domain model.
  TitleGenre toDomain() => TitleGenre(name: name, ru: ru, en: en);
}
