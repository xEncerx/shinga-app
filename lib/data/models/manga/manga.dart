import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../core/core.dart';
part 'manga.freezed.dart';
part 'manga.g.dart';

@freezed
abstract class Manga with _$Manga {
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
