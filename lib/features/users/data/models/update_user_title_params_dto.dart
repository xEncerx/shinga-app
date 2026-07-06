import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:shinga/features/features.dart';

part 'update_user_title_params_dto.freezed.dart';
part 'update_user_title_params_dto.g.dart';

/// Data Transfer Object for updating user-specific data related to a title.
@freezed
abstract class UpdateUserTitleParamsDTO with _$UpdateUserTitleParamsDTO {
  /// Creates an [UpdateUserTitleParamsDTO] instance.
  const factory UpdateUserTitleParamsDTO({
    @JsonKey(includeIfNull: false) BookmarkDTO? bookmark,
    @JsonKey(includeIfNull: false) double? rating,
    @JsonKey(includeIfNull: false) bool? isFavorite,
    @JsonKey(includeIfNull: false) String? currentUrl,
    @JsonKey(includeIfNull: false) String? note,
  }) = _UpdateUserTitleParamsDTO;

  /// Converts a domain [UpdateUserTitleParams] to a DTO.
  factory UpdateUserTitleParamsDTO.fromDomain(UpdateUserTitleParams params) {
    return UpdateUserTitleParamsDTO(
      bookmark: params.bookmark != null ? BookmarkDTO.fromDomain(params.bookmark!) : null,
      rating: params.rating,
      isFavorite: params.isFavorite,
      currentUrl: params.currentUrl,
      note: params.note,
    );
  }

  /// Creates an instance of [UpdateUserTitleParamsDTO] from a JSON map.
  factory UpdateUserTitleParamsDTO.fromJson(Map<String, dynamic> json) =>
      _$UpdateUserTitleParamsDTOFromJson(json);
}
