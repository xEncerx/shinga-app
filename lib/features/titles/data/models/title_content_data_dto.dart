import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:shinga/features/features.dart';

part 'title_content_data_dto.freezed.dart';
part 'title_content_data_dto.g.dart';

/// DTO representing a single title content wrapper.
@freezed
abstract class TitleContentDataDTO with _$TitleContentDataDTO {
  /// Creates a [TitleContentDataDTO] instance.
  const factory TitleContentDataDTO({
    /// The title data with user-specific data.
    required TitleWithUserDataDTO content,
  }) = _TitleContentDataDTO;

  /// Creates a [TitleContentDataDTO] instance from a JSON map.
  factory TitleContentDataDTO.fromJson(Map<String, dynamic> json) =>
      _$TitleContentDataDTOFromJson(json);
}
