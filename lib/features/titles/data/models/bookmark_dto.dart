import 'package:json_annotation/json_annotation.dart';
import 'package:shinga/domain/domain.dart';

/// Represents the reading status of a title for a user.
@JsonEnum(valueField: 'value')
enum BookmarkDTO {
  /// The user has not started reading the title.
  notReading('not_reading'),

  /// The user is currently reading the title.
  reading('reading'),

  /// The user has finished reading the title.
  completed('completed'),

  /// The user has dropped the title mid-read.
  dropped('dropped'),

  /// The user plans to read the title in the future.
  planning('planning');

  const BookmarkDTO(this.value);

  /// The string value corresponding to the enum case, matching API responses.
  final String value;

  @override
  String toString() => value;

  /// Converts this DTO to the [Bookmark] domain entity.
  Bookmark toDomain() => switch (this) {
    BookmarkDTO.notReading => Bookmark.notReading,
    BookmarkDTO.reading => Bookmark.reading,
    BookmarkDTO.completed => Bookmark.completed,
    BookmarkDTO.dropped => Bookmark.dropped,
    BookmarkDTO.planning => Bookmark.planning,
  };

  /// Converts a [Bookmark] domain entity to this DTO.
  static BookmarkDTO fromDomain(Bookmark bookmark) => switch (bookmark) {
    Bookmark.notReading => BookmarkDTO.notReading,
    Bookmark.reading => BookmarkDTO.reading,
    Bookmark.completed => BookmarkDTO.completed,
    Bookmark.dropped => BookmarkDTO.dropped,
    Bookmark.planning => BookmarkDTO.planning,
  };

  /// Creates a [BookmarkDTO] from a string value, throwing an error if the value is unknown.
  static BookmarkDTO fromString(String value) => BookmarkDTO.values.firstWhere(
    (e) => e.value == value,
    orElse: () => throw ArgumentError.value(value, 'value', 'Unknown bookmark status'),
  );
}
