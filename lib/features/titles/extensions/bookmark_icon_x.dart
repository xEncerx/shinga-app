import 'package:shinga/domain/domain.dart';
import 'package:ui_kit/ui_kit.dart';

/// Extension on [Bookmark] to resolve its icon.
extension BookmarkIconX on Bookmark {
  /// Returns the [SaIconSource] icon corresponding to this [Bookmark] status.
  SaIconSource get icon => switch (this) {
    Bookmark.reading => const SaIconSource.huge(HugeIconsStrokeRounded.bookOpen02),
    Bookmark.completed => const SaIconSource.huge(HugeIconsStrokeRounded.checkmarkCircle02),
    Bookmark.dropped => const SaIconSource.huge(HugeIconsStrokeRounded.heartbreak),
    Bookmark.planning => const SaIconSource.huge(HugeIconsStrokeRounded.clock04),
    Bookmark.notReading => const SaIconSource.huge(HugeIconsStrokeRounded.delete01),
  };
}
