import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:shinga/domain/domain.dart';
import 'package:shinga/features/features.dart';

part 'title_status_form_dto.freezed.dart';
part 'title_status_form_dto.g.dart';

/// DTO for a single publication status form option returned by the API.
@freezed
abstract class TitleStatusFormDTO with _$TitleStatusFormDTO {
  /// Creates a [TitleStatusFormDTO] instance.
  const factory TitleStatusFormDTO({
    /// The canonical identifier name of the status in the system.
    required String name,
  }) = _TitleStatusFormDTO;

  const TitleStatusFormDTO._();

  /// Creates a [TitleStatusFormDTO] instance from a JSON map.
  factory TitleStatusFormDTO.fromJson(Map<String, dynamic> json) =>
      _$TitleStatusFormDTOFromJson(json);

  /// Converts this DTO to a [TitleStatus] domain model.
  TitleStatus toDomain() => TitleStatusDTO.fromValue(name).toDomain();
}

/// DTO wrapping a list of [TitleStatusFormDTO] items returned under the `content` key.
@freezed
abstract class TitleStatusFormsResponseDTO with _$TitleStatusFormsResponseDTO {
  /// Creates a [TitleStatusFormsResponseDTO] instance.
  const factory TitleStatusFormsResponseDTO({
    /// The list of status form options.
    required List<TitleStatusFormDTO> content,
  }) = _TitleStatusFormsResponseDTO;

  /// Creates a [TitleStatusFormsResponseDTO] instance from a JSON map.
  factory TitleStatusFormsResponseDTO.fromJson(Map<String, dynamic> json) =>
      _$TitleStatusFormsResponseDTOFromJson(json);
}
