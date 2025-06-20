import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../core/core.dart';
part 'manga.freezed.dart';
part 'manga.g.dart';

@freezed
abstract class Manga with _$Manga {
  /// Represents a manga with various attributes.
  /// - `id` - Unique identifier for the manga.
  /// - `sourceId` - Identifier for the source of the manga.
  /// - `sourceName` - Name of the source where the manga is found.
  /// - `name` - Name of the manga.
  /// - `slug` - Slug for the manga, typically used in URLs.
  /// - `altNames` - Alternative names for the manga.
  /// - `description` - Description of the manga.
  /// - `avgRating` - Average rating of the manga.
  /// - `views` - Number of views the manga has received.
  /// - `chapters` - Number of chapters in the manga.
  /// - `cover` - URL to the cover image of the manga.
  /// - `status` - Current status of the manga (e.g., ongoing, completed).
  /// - `translateStatus` - Translation status of the manga.
  /// - `year` - Year of publication or release.
  /// - `genres` - Genres associated with the manga.
  /// - `categories` - Categories associated with the manga.
  /// - `lastUpdate` - Date and time of the last update to the manga (in API).
  /// - User values:
  /// - `currentUrl` - Current URL of the manga.
  /// - `section` - Current reading section of the manga, represented by the `MangaSection` enum.
  /// - `lastRead` - Date and time when the manga was last read.
  /// - App flags:
  /// - `isSaved` - Indicates whether the manga is saved in the API collection.
  @JsonSerializable(fieldRename: FieldRename.snake)
  const factory Manga({
    required String id,
    required String sourceId,
    required String sourceName,
    required String name,
    required String slug,
    required String altNames,
    required String description,
    required String avgRating,
    required int views,
    required int chapters,
    required String cover,
    required String status,
    required String translateStatus,
    required int? year,
    required String genres,
    required String categories,
    required DateTime lastUpdate,
    String? currentUrl,
    @JsonKey(fromJson: MangaSectionConverter.fromJson, toJson: MangaSectionConverter.toJson)
    @Default(MangaSection.notReading)
    MangaSection section,
    DateTime? lastRead,
    @Default(false)
    bool isSaved,
  }) = _Manga;

  factory Manga.fromJson(Map<String, dynamic> json) => _$MangaFromJson(json);
}

// Converter to handle the conversion of MangaSection enum to/from JSON
class MangaSectionConverter {
  static MangaSection fromJson(String? json) {
    if (json == null) return MangaSection.notReading;

    try {
      return MangaSection.values.firstWhere(
        (section) => section.name == json,
      );
    } catch (_) {
      return MangaSection.notReading;
    }
  }

  static String toJson(MangaSection? object) {
    return object?.name ?? MangaSection.notReading.name;
  }
}
