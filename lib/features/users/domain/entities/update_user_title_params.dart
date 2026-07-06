import 'package:shinga/domain/domain.dart';

/// Parameters for updating user-specific data for a title.
///
/// Based on UserTitleDataEntity, but all fields are optional since the user may choose to update only a subset of their data for a title.
class UpdateUserTitleParams {
  /// Creates an [UpdateUserTitleParams] instance.
  UpdateUserTitleParams({
    this.rating,
    this.bookmark,
    this.isFavorite,
    this.currentUrl,
    this.note,
  });

  /// The user's rating for the title, if updating.
  final double? rating;

  /// The user's bookmark for the title, if updating.
  final Bookmark? bookmark;

  /// Whether the title is marked as a favorite by the user, if updating.
  final bool? isFavorite;

  /// The current URL for the title, if updating.
  final String? currentUrl;

  /// The user's note for the title, if updating.
  final String? note;
}
