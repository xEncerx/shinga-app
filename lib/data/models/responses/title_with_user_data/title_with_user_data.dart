import 'package:freezed_annotation/freezed_annotation.dart';

import '../../title/title.dart';
import '../../user/user.dart';

part 'title_with_user_data.freezed.dart';
part 'title_with_user_data.g.dart';

@freezed
abstract class TitleWithUserData with _$TitleWithUserData {
  @JsonSerializable(fieldRename: FieldRename.snake)
  const factory TitleWithUserData({
    required TitleData title,
    UserTitleData? userData,
  }) = _TitleWithUserData;

  factory TitleWithUserData.fromJson(Map<String, dynamic> json) =>
      _$TitleWithUserDataFromJson(json);
}
