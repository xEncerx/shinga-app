import 'package:json_annotation/json_annotation.dart';
import 'package:shinga/domain/domain.dart';

/// The publication format of a title.
@JsonEnum(valueField: 'value')
enum TitleTypeDTO {
  /// Japanese manga.
  manga('manga'),

  /// Written novel.
  novel('novel'),

  /// Japanese light novel.
  lightNovel('light_novel'),

  /// A single-chapter, self-contained story.
  oneshot('oneshot'),

  /// A self-published or fan-made work.
  doujinshi('doujin'),

  /// Korean manhwa.
  manhwa('manhwa'),

  /// Chinese manhua.
  manhua('manhua'),

  /// Western-style comics.
  comics('comics'),

  /// Vertically scrolling digital comic.
  webtoon('webtoon'),

  /// A format that does not fit any other category.
  other('other');

  const TitleTypeDTO(this.value);

  /// The string value corresponding to the enum case, matching API responses.
  final String value;

  @override
  String toString() => value;

  /// Converts a string value from the API to the corresponding [TitleTypeDTO] enum case.
  static TitleTypeDTO fromValue(String value) => TitleTypeDTO.values.firstWhere(
    (e) => e.value == value,
    orElse: () => TitleTypeDTO.other,
  );

  /// Converts this DTO to the [TitleType] domain entity.
  TitleType toDomain() => switch (this) {
    TitleTypeDTO.manga => TitleType.manga,
    TitleTypeDTO.novel => TitleType.novel,
    TitleTypeDTO.lightNovel => TitleType.lightNovel,
    TitleTypeDTO.oneshot => TitleType.oneshot,
    TitleTypeDTO.doujinshi => TitleType.doujinshi,
    TitleTypeDTO.manhwa => TitleType.manhwa,
    TitleTypeDTO.manhua => TitleType.manhua,
    TitleTypeDTO.comics => TitleType.comics,
    TitleTypeDTO.webtoon => TitleType.webtoon,
    TitleTypeDTO.other => TitleType.other,
  };

  /// Converts a [TitleType] domain entity to this DTO.
  static TitleTypeDTO fromDomain(TitleType type) => switch (type) {
    TitleType.manga => TitleTypeDTO.manga,
    TitleType.novel => TitleTypeDTO.novel,
    TitleType.lightNovel => TitleTypeDTO.lightNovel,
    TitleType.oneshot => TitleTypeDTO.oneshot,
    TitleType.doujinshi => TitleTypeDTO.doujinshi,
    TitleType.manhwa => TitleTypeDTO.manhwa,
    TitleType.manhua => TitleTypeDTO.manhua,
    TitleType.comics => TitleTypeDTO.comics,
    TitleType.webtoon => TitleTypeDTO.webtoon,
    TitleType.other => TitleTypeDTO.other,
  };
}
