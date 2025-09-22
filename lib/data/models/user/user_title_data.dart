import 'package:freezed_annotation/freezed_annotation.dart';

import '../title/relations/relations.dart';
import 'relations/relations.dart';

part 'user_title_data.freezed.dart';
part 'user_title_data.g.dart';

@freezed
abstract class UserTitleData with _$UserTitleData {
  /// Represents a user's title data.
  /// - `user_id` - The ID of the user.
  /// - `titleId` - The unique identifier of the title.
  /// - `userRating` - The user's rating for the title.
  /// - `currentUrl` - The current URL of the title.
  /// - `bookmark` - The bookmark type associated with the title.
  /// - `updatedAt` - The last updated date and time of the title data.
  @JsonSerializable(fieldRename: FieldRename.snake)
  const factory UserTitleData({
    required int userId,
    required String titleId,
    required int userRating,
    required String currentUrl,
    @BookMarkTypeConverter() required BookMarkType bookmark,
    @DateTimeConverter() required DateTime updatedAt,
  }) = _UserTitleData;

  factory UserTitleData.fromJson(Map<String, dynamic> json) =>
      _$UserTitleDataFromJson(json);
}
