import 'package:flutter/material.dart';

import '../core.dart';

/// Returns a highlight color based on the manga section.
///
/// Each manga section has a designated color for visual identification.
Color getHighLightColor(MangaSection section) {
  switch (section) {
    case MangaSection.completed:
      return AppTheme.completedHighLight;
    case MangaSection.onFuture:
      return AppTheme.onFutureHighLight;
    case MangaSection.notReading:
      return AppTheme.notReadingHighLight;
    case MangaSection.reading:
      return AppTheme.readingHighLight;
    case MangaSection.any:
      return Colors.transparent;
  }
}

/// Returns an icon representing the manga section.
///
/// Each manga section has a unique icon for visual identification.
IconData getSectionIcon(MangaSection section) {
  switch (section) {
    case MangaSection.completed:
      return Icons.check_circle_outline_rounded;
    case MangaSection.onFuture:
      return Icons.schedule_outlined;
    case MangaSection.notReading:
      return Icons.cancel_outlined;
    case MangaSection.reading:
      return Icons.play_circle_outline_rounded;
    case MangaSection.any:
      return Icons.question_mark_rounded;
  }
}
