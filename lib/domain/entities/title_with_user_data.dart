import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:shinga/domain/domain.dart';

part 'title_with_user_data.freezed.dart';

/// A title paired with the current user's personal data for it.
@freezed
abstract class TitleWithUserDataEntity with _$TitleWithUserDataEntity {
  /// Creates a [TitleWithUserDataEntity] instance.
  const factory TitleWithUserDataEntity({
    /// The title entity.
    required TitleEntity title,

    /// The user-specific data associated with [title].
    UserTitleDataEntity? userData,
  }) = _TitleWithUserDataEntity;
}
