import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:shinga/domain/domain.dart';

part 'title_category_dto.freezed.dart';
part 'title_category_dto.g.dart';

/// A data model representing a category of a title, as received from the API.
@freezed
abstract class TitleCategoryDTO with _$TitleCategoryDTO {
  /// Creates a [TitleCategoryDTO] instance.
  const factory TitleCategoryDTO({
    required String name,
    required String ru,
    required String en,
  }) = _TitleCategoryDTO;

  const TitleCategoryDTO._();

  /// Creates a [TitleCategoryDTO] instance from a JSON map.
  factory TitleCategoryDTO.fromJson(Map<String, dynamic> json) => _$TitleCategoryDTOFromJson(json);

  /// Creates a [TitleCategoryDTO] from a [TitleCategory] domain model.
  factory TitleCategoryDTO.fromDomain(TitleCategory category) => TitleCategoryDTO(
    name: category.name,
    ru: category.ru,
    en: category.en,
  );

  /// Converts this [TitleCategoryDTO] to a [TitleCategory] domain model.
  TitleCategory toDomain() => TitleCategory(name: name, ru: ru, en: en);
}
