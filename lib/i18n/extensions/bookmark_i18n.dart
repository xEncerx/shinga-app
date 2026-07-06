import 'package:shinga/domain/domain.dart';
import 'package:shinga/i18n/strings.g.dart';

/// Extension on [Bookmark] to resolve its localized string representation.
extension BookmarkI18n on Bookmark {
  /// Returns the localized string corresponding to this [Bookmark] status.
  String get i18n => switch (this) {
    Bookmark.reading => t.userTitles.bookmark.reading,
    Bookmark.completed => t.userTitles.bookmark.completed,
    Bookmark.dropped => t.userTitles.bookmark.dropped,
    Bookmark.planning => t.userTitles.bookmark.planning,
    Bookmark.notReading => t.userTitles.bookmark.notReading,
  };
}
