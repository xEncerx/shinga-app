import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:shinga/domain/domain.dart';
import 'package:shinga/features/features.dart';

part 'user_title_data_dto.freezed.dart';
part 'user_title_data_dto.g.dart';

/// A data model representing user-specific data for a title, as received from the API.
@freezed
abstract class UserTitleDataDTO with _$UserTitleDataDTO {
  /// Creates a [UserTitleDataDTO] instance.
  const factory UserTitleDataDTO({
    required double rating,
    required BookmarkDTO bookmark,
    required bool isFavorite,
    required String? currentUrl,
    required String? note,
  }) = _UserTitleDataDTO;

  const UserTitleDataDTO._();

  /// Creates a [UserTitleDataDTO] instance from a JSON map.
  factory UserTitleDataDTO.fromJson(Map<String, dynamic> json) => _$UserTitleDataDTOFromJson(json);

  /// Converts this [UserTitleDataDTO] to a [UserTitleDataEntity] domain entity.
  UserTitleDataEntity toDomain() {
    return UserTitleDataEntity(
      rating: rating,
      bookmark: bookmark.toDomain(),
      isFavorite: isFavorite,
      currentUrl: currentUrl,
      note: note,
    );
  }
}
