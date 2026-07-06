import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:shinga/domain/domain.dart';
import 'package:shinga/features/features.dart';

part 'user_statistics_dto.freezed.dart';
part 'user_statistics_dto.g.dart';

/// A DTO representing the current user's aggregated statistics.
@freezed
abstract class UserStatisticsDTO with _$UserStatisticsDTO {
  /// Creates a [UserStatisticsDTO] instance.
  const factory UserStatisticsDTO({
    required UserBookmarkStatisticsDTO bookmarks,
    required UserRatingStatisticsDTO ratings,
  }) = _UserStatisticsDTO;

  const UserStatisticsDTO._();

  /// Deserializes a [UserStatisticsDTO] from [json].
  factory UserStatisticsDTO.fromJson(Map<String, Object?> json) =>
      _$UserStatisticsDTOFromJson(json);

  /// Maps this DTO to the [UserStatisticsEntity] domain entity.
  UserStatisticsEntity toDomain() => UserStatisticsEntity(
    bookmarks: bookmarks.toDomain(),
    ratings: ratings.toDomain(),
  );
}

/// A DTO representing bookmark statistics returned by the API.
@freezed
abstract class UserBookmarkStatisticsDTO with _$UserBookmarkStatisticsDTO {
  /// Creates a [UserBookmarkStatisticsDTO] instance.
  const factory UserBookmarkStatisticsDTO({
    required Map<String, int> bookmarks,
    required int total,
  }) = _UserBookmarkStatisticsDTO;

  const UserBookmarkStatisticsDTO._();

  /// Deserializes a [UserBookmarkStatisticsDTO] from [json].
  factory UserBookmarkStatisticsDTO.fromJson(Map<String, Object?> json) =>
      _$UserBookmarkStatisticsDTOFromJson(json);

  /// Maps this DTO to the [UserBookmarkStatisticsEntity] domain entity.
  UserBookmarkStatisticsEntity toDomain() => UserBookmarkStatisticsEntity(
    bookmarks: Map.unmodifiable({
      for (final bookmark in Bookmark.aValues) bookmark: 0,
      for (final entry in bookmarks.entries) _bookmarkFromApiValue(entry.key): entry.value,
    }),
    total: total,
  );
}

/// A DTO representing rating statistics returned by the API.
@freezed
abstract class UserRatingStatisticsDTO with _$UserRatingStatisticsDTO {
  /// Creates a [UserRatingStatisticsDTO] instance.
  const factory UserRatingStatisticsDTO({
    @JsonKey(name: 'average_rating') required double averageRating,
    @JsonKey(name: 'ratings_count') required int ratingsCount,
    @JsonKey(name: 'ratings_distribution') required Map<String, int> ratingsDistribution,
  }) = _UserRatingStatisticsDTO;

  const UserRatingStatisticsDTO._();

  /// Deserializes a [UserRatingStatisticsDTO] from [json].
  factory UserRatingStatisticsDTO.fromJson(Map<String, Object?> json) =>
      _$UserRatingStatisticsDTOFromJson(json);

  /// Maps this DTO to the [UserRatingStatisticsEntity] domain entity.
  UserRatingStatisticsEntity toDomain() => UserRatingStatisticsEntity(
    averageRating: averageRating,
    ratingsCount: ratingsCount,
    ratingsDistribution: Map.unmodifiable(
      ratingsDistribution.map((key, value) => MapEntry(int.parse(key), value)),
    ),
  );
}

Bookmark _bookmarkFromApiValue(String value) => BookmarkDTO.fromString(value).toDomain();
