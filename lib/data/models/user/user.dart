import 'package:freezed_annotation/freezed_annotation.dart';

import 'relations/relations.dart';
export 'relations/relations.dart';
export 'user_title_data.dart';

part 'user.freezed.dart';
part 'user.g.dart';

@freezed
abstract class UserData with _$UserData {
  /// Represents a public user profile.
  /// - `username` - The username of the user.
  /// - `email` - The email address of the user.
  /// - `isStaff` - Indicates if the user is a staff member.
  /// - `isSuperuser` - Indicates if the user is a superuser.
  /// - `avatar` - The URL or path to the user's avatar image.
  /// - `avgRating` - The average rating given by the user.
  /// - `countLikes` - The total number of likes the user has received.
  /// - `countVotes` - The total number of votes the user has cast.
  /// - `countComments` - The total number of comments made by the user.
  /// - `countBookmarks` - The count of bookmarks associated with the user.
  /// - `description` - A brief description or bio of the user.
  /// - `extraData` - Additional data related to the user, if any.
  @JsonSerializable(fieldRename: FieldRename.snake)
  const factory UserData({
    required String username,
    required String email,
    required bool isStaff,
    required bool isSuperuser,
    required String avatar,
    required double avgRating,
    required int countLikes,
    required int countVotes,
    required int countComments,
    required BookMarksCount countBookmarks,
    String? description,
    Map<String, dynamic>? extraData,
  }) = _UserData;

  factory UserData.fromJson(Map<String, dynamic> json) => _$UserDataFromJson(json);

  /// Creates a dummy UserData
  static const UserData dummy = UserData(
    username: '???',
    email: 'loading@example.com',
    isStaff: false,
    isSuperuser: false,
    avatar: '',
    avgRating: 0.0,
    countLikes: 0,
    countVotes: 0,
    countComments: 0,
    countBookmarks: BookMarksCount.dummy,
  );
}
