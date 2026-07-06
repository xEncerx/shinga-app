import 'package:shinga/domain/domain.dart';
import 'package:shinga/i18n/strings.g.dart';

/// Extension on [TitleType] to provide internationalized strings.
extension TitleTypeI18n on TitleType {
  /// Returns the internationalized string corresponding to this [TitleType].
  String get i18n => switch (this) {
    TitleType.manga => t.titles.types.manga,
    TitleType.novel => t.titles.types.novel,
    TitleType.lightNovel => t.titles.types.lightNovel,
    TitleType.oneshot => t.titles.types.oneshot,
    TitleType.doujinshi => t.titles.types.doujinshi,
    TitleType.manhwa => t.titles.types.manhwa,
    TitleType.manhua => t.titles.types.manhua,
    TitleType.comics => t.titles.types.comics,
    TitleType.webtoon => t.titles.types.webtoon,
    TitleType.other => t.titles.types.other,
  };
}
