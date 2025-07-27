import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../../core/core.dart';
import '../../../../i18n/strings.g.dart';

part 'bookmarks.freezed.dart';
part 'bookmarks.g.dart';

enum BookMarkType {
  notReading('not reading', Colors.transparent, Icons.bookmark_border),
  completed('completed', AppTheme.completedHighLight, Icons.check_circle_outline_rounded),
  reading('reading', AppTheme.readingHighLight, Icons.play_circle_outline_rounded),
  planned('planned', AppTheme.plannedHighLight, Icons.schedule_rounded),
  dropped('dropped', AppTheme.droppedHighLight, Icons.cancel_outlined);

  const BookMarkType(this.value, this.color, this.icon);

  final String value;
  final Color color;
  final IconData icon;

  /// Returns a list of available for using bookmark.
  static const List<BookMarkType> aValues = [
    completed,
    reading,
    planned,
    dropped,
  ];

  /// Returns a BookMarkType from a string value.
  static BookMarkType fromString(String value) {
    return values.firstWhere(
      (e) => e.value == value,
      orElse: () => BookMarkType.notReading, // fallback
    );
  }

  /// Returns the internationalized string for the bookmark type.
  String get i18n {
    switch (this) {
      case BookMarkType.notReading:
        return t.bookmarks.notReading;
      case BookMarkType.reading:
        return t.bookmarks.reading;
      case BookMarkType.completed:
        return t.bookmarks.completed;
      case BookMarkType.dropped:
        return t.bookmarks.dropped;
      case BookMarkType.planned:
        return t.bookmarks.planned;
    }
  }
}

class BookMarkTypeConverter implements JsonConverter<BookMarkType, String> {
  const BookMarkTypeConverter();

  @override
  BookMarkType fromJson(String json) => BookMarkType.fromString(json);

  @override
  String toJson(BookMarkType object) => object.value;
}

@freezed
abstract class BookMarksCount with _$BookMarksCount {
  /// Represents the count of bookmarks for a user.
  /// - `total` - Total number of bookmarks.
  /// - `notReading` - Number of bookmarks not currently being read.
  /// - `reading` - Number of bookmarks currently being read.
  /// - `completed` - Number of bookmarks that have been completed.
  /// - `dropped` - Number of bookmarks that have been dropped.
  /// - `planned` - Number of bookmarks that are planned to be read.
  @JsonSerializable(fieldRename: FieldRename.snake)
  const factory BookMarksCount({
    required int total,
    required int notReading,
    required int reading,
    required int completed,
    required int dropped,
    required int planned,
  }) = _BookMarksCount;

  factory BookMarksCount.fromJson(Map<String, dynamic> json) => _$BookMarksCountFromJson(json);

  /// Creates a dummy BookMarksCount with all values set to 0
  static const BookMarksCount dummy = BookMarksCount(
    total: 0,
    notReading: 0,
    reading: 0,
    completed: 0,
    dropped: 0,
    planned: 0,
  );
}
