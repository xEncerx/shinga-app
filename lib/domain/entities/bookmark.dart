/// Represents the reading status of a title for a user.
enum Bookmark {
  /// The user has not started reading the title.
  notReading,

  /// The user has finished reading the title.
  completed,

  /// The user is currently reading the title.
  reading,

  /// The user plans to read the title in the future.
  planning,

  /// The user has dropped the title mid-read.
  dropped;

  /// All available bookmark statuses except [notReading].
  static const List<Bookmark> aValues = [
    Bookmark.completed,
    Bookmark.reading,
    Bookmark.planning,
    Bookmark.dropped,
  ];
}
