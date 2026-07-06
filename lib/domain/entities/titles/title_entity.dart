import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:shinga/domain/domain.dart';

part 'title_entity.freezed.dart';

/// A manga/novel title with all of its metadata.
@freezed
abstract class TitleEntity with _$TitleEntity {
  /// Creates a [TitleEntity] instance.
  const factory TitleEntity({
    /// The unique identifier of the title.
    required int id,

    /// Alternative names or synonyms for the title.
    required List<String> altNames,

    /// The publication format of the title.
    required TitleType type,

    /// The current publication status of the title.
    required TitleStatus status,

    /// The popularity rank of the title.
    required int popularity,

    /// The total number of chapters released.
    required int chapters,

    /// The total number of views the title has received.
    required int views,

    /// The total number of volumes released.
    required int volumes,

    /// The number of times the title has been added to favorites.
    required int favorites,

    /// The average community rating of the title.
    required double rating,

    /// The number of users who have scored the title.
    required int scoredBy,

    /// The date the title was first released.
    required DateTime? releasedAt,

    /// The date the title ended, or its scheduled end date.
    required DateTime? endedAt,

    /// The genres associated with the title.
    required List<TitleGenre> genres,

    /// The categories associated with the title.
    required List<TitleCategory> categories,

    /// The authors of the title.
    required List<String> authors,

    /// The cover images of the title.
    required TitleCoverEntity cover,

    /// The corresponding MyAnimeList identifier, if available.
    int? malId,

    /// The title name in Russian, if available.
    String? nameRu,

    /// The title name in English, if available.
    String? nameEn,

    /// The description of the title in Russian, if available.
    String? descriptionRu,

    /// The description of the title in English, if available.
    String? descriptionEn,
  }) = _TitleEntity;
}
