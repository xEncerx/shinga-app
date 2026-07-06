import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:shinga/domain/domain.dart';

part 'title_category_form_dto.freezed.dart';
part 'title_category_form_dto.g.dart';

/// DTO for a single category form option returned by the API.
@freezed
abstract class TitleCategoryFormDTO with _$TitleCategoryFormDTO {
  /// Creates a [TitleCategoryFormDTO] instance.
  const factory TitleCategoryFormDTO({
    /// The canonical identifier name of the category in the system.
    required String name,

    /// The category name in Russian.
    required String ru,

    /// The category name in English.
    required String en,
  }) = _TitleCategoryFormDTO;

  const TitleCategoryFormDTO._();

  /// Creates a [TitleCategoryFormDTO] instance from a JSON map.
  factory TitleCategoryFormDTO.fromJson(Map<String, dynamic> json) =>
      _$TitleCategoryFormDTOFromJson(json);

  /// Converts this DTO to a [TitleCategory] domain model.
  TitleCategory toDomain() => TitleCategory(name: name, ru: ru, en: en);
}

/// DTO wrapping a list of [TitleCategoryFormDTO] items returned under the `content` key.
@freezed
abstract class TitleCategoryFormsResponseDTO with _$TitleCategoryFormsResponseDTO {
  /// Creates a [TitleCategoryFormsResponseDTO] instance.
  const factory TitleCategoryFormsResponseDTO({
    /// The list of category form options.
    required List<TitleCategoryFormDTO> content,
  }) = _TitleCategoryFormsResponseDTO;

  /// Creates a [TitleCategoryFormsResponseDTO] instance from a JSON map.
  factory TitleCategoryFormsResponseDTO.fromJson(Map<String, dynamic> json) =>
      _$TitleCategoryFormsResponseDTOFromJson(json);
}
