import 'package:freezed_annotation/freezed_annotation.dart';

import 'relations/relations.dart';
export 'relations/relations.dart';

part 'title.freezed.dart';
part 'title.g.dart';

@freezed
abstract class TitleData with _$TitleData {
  /// Represents a title in the application.
  /// `id` - Unique identifier for the title.
  /// `nameEn` - English name of the title.
  /// `nameRu` - Russian name of the title.
  /// `cover` - Cover data for the title.
  /// `altNames` - List of alternative names for the title.
  /// `type` - Type of the title (e.g., manga, manhwa).
  /// `chapters` - Number of chapters in the title.
  /// `volumes` - Number of volumes in the title.
  /// `views` - Number of views the title has received.
  /// `inAppRating` - In-app rating of the title.
  /// `inAppScoredBy` - Number of users who scored the title in the app.
  /// `status` - Current status of the title (e.g., ongoing, completed).
  /// `date` - Release time of the title.
  /// `rating` - Overall rating of the title.
  /// `scoredBy` - Number of users who scored the title.
  /// `popularity` - Popularity score of the title.
  /// `favorites` - Number of users who favorited the title.
  /// `description` - Description data for the title.
  /// `authors` - List of authors of the title.
  /// `genres` - List of genres associated with the title.
  /// `extraData` - Additional data related to the title, if any.
  @JsonSerializable(fieldRename: FieldRename.snake)
  const factory TitleData({
    required String id,
    String? nameEn,
    String? nameRu,
    required CoverData cover,
    required List<String> altNames,
    @JsonKey(name: 'type_') @TitleTypeConverter() required TitleType type,
    required int chapters,
    required int volumes,
    required int views,
    required int inAppRating,
    required int inAppScoredBy,
    @TitleStatusConverter() required TitleStatus status,
    required TitleReleaseTime date,
    required double rating,
    required int scoredBy,
    required int popularity,
    required int favorites,
    required DescriptionData description,
    required List<String> authors,
    required List<GenreData> genres,
    @DateTimeConverter() required DateTime updatedAt,
    Map<String, dynamic>? extraData,
  }) = _TitleData;

  factory TitleData.fromJson(Map<String, dynamic> json) => _$TitleDataFromJson(json);
}
