import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:shinga/domain/domain.dart';
import 'package:shinga/features/features.dart';

part 'title_type_form_dto.freezed.dart';
part 'title_type_form_dto.g.dart';

/// DTO for a single publication type form option returned by the API.
@freezed
abstract class TitleTypeFormDTO with _$TitleTypeFormDTO {
  /// Creates a [TitleTypeFormDTO] instance.
  const factory TitleTypeFormDTO({
    /// The canonical identifier name of the type in the system.
    required String name,
  }) = _TitleTypeFormDTO;

  const TitleTypeFormDTO._();

  /// Creates a [TitleTypeFormDTO] instance from a JSON map.
  factory TitleTypeFormDTO.fromJson(Map<String, dynamic> json) => _$TitleTypeFormDTOFromJson(json);

  /// Converts this DTO to a [TitleType] domain model.
  TitleType toDomain() => TitleTypeDTO.fromValue(name).toDomain();
}

/// DTO wrapping a list of [TitleTypeFormDTO] items returned under the `content` key.
@freezed
abstract class TitleTypeFormsResponseDTO with _$TitleTypeFormsResponseDTO {
  /// Creates a [TitleTypeFormsResponseDTO] instance.
  const factory TitleTypeFormsResponseDTO({
    /// The list of type form options.
    required List<TitleTypeFormDTO> content,
  }) = _TitleTypeFormsResponseDTO;

  /// Creates a [TitleTypeFormsResponseDTO] instance from a JSON map.
  factory TitleTypeFormsResponseDTO.fromJson(Map<String, dynamic> json) =>
      _$TitleTypeFormsResponseDTOFromJson(json);
}
