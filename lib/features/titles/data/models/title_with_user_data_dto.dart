import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:shinga/domain/domain.dart';
import 'package:shinga/features/features.dart';

part 'title_with_user_data_dto.freezed.dart';
part 'title_with_user_data_dto.g.dart';

/// A data model representing a title along with user-specific data, as received from the API.
@freezed
abstract class TitleWithUserDataDTO with _$TitleWithUserDataDTO {
  /// Creates a [TitleWithUserDataDTO] instance.
  const factory TitleWithUserDataDTO({
    required TitleDTO title,
    UserTitleDataDTO? userData,
  }) = _TitleWithUserDataDTO;

  const TitleWithUserDataDTO._();

  /// Creates a [TitleWithUserDataDTO] instance from a JSON map.
  factory TitleWithUserDataDTO.fromJson(Map<String, dynamic> json) =>
      _$TitleWithUserDataDTOFromJson(json);

  /// Converts this [TitleWithUserDataDTO] to a [TitleWithUserDataEntity] domain entity.
  TitleWithUserDataEntity toDomain() {
    return TitleWithUserDataEntity(
      title: title.toDomain(),
      userData: userData?.toDomain(),
    );
  }
}
