import 'package:flutter/material.dart';
import 'package:shinga/domain/domain.dart';
import 'package:ui_kit/ui_kit.dart';

/// Extension on [Bookmark] to resolve its highlight color from the current theme.
extension BookmarkColorX on Bookmark {
  /// Returns the [AppColors] highlight color corresponding to this [Bookmark] status.
  Color? highlightColor(AppColors colors) => switch (this) {
    Bookmark.reading => colors.bookmarkReading,
    Bookmark.completed => colors.bookmarkCompleted,
    Bookmark.dropped => colors.bookmarkDropped,
    Bookmark.planning => colors.bookmarkPlanning,
    Bookmark.notReading => null,
  };
}
