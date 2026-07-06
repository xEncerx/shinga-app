import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:shinga/domain/domain.dart';

part 'user_title_data.freezed.dart';

/// User-specific data associated with a title.
@freezed
abstract class UserTitleDataEntity with _$UserTitleDataEntity {
  /// Creates a [UserTitleDataEntity] instance.
  const factory UserTitleDataEntity({
    /// The user's reading status bookmark for the title.
    required Bookmark bookmark,

    /// The user's personal rating for the title.
    @Default(0.0) double rating,

    /// Whether the user has marked the title as a favorite.
    @Default(false) bool isFavorite,

    /// The URL of the chapter the user is currently reading.
    String? currentUrl,

    /// An optional personal note left by the user for the title.
    String? note,
  }) = _UserTitleDataEntity;
}
