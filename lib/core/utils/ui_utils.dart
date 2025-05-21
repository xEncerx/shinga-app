import 'package:flutter/material.dart';

import '../core.dart';

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
