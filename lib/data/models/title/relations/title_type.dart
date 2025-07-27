import 'package:json_annotation/json_annotation.dart';

import '../../../../i18n/strings.g.dart';

enum TitleType {
  manga('manga'),
  novel('novel'),
  lightNovel('light novel'),
  oneshot('one-shot'),
  doujin('doujinshi'),
  manhwa('manhwa'),
  manhua('manhua'),
  comics('comics'),
  webtoon('webtoon'),
  other('other');

  const TitleType(this.value);
  final String value;

  // Метод для преобразования строки в enum
  static TitleType fromString(String value) {
    return values.firstWhere(
      (e) => e.value == value,
      orElse: () => TitleType.other,
    );
  }

  /// Returns the internationalized string for the title type.
  String get i18n {
    switch (this) {
      case TitleType.manga:
        return t.titleTypes.manga;
      case TitleType.novel:
        return t.titleTypes.novel;
      case TitleType.lightNovel:
        return t.titleTypes.lightNovel;
      case TitleType.oneshot:
        return t.titleTypes.oneshot;
      case TitleType.doujin:
        return t.titleTypes.doujin;
      case TitleType.manhwa:
        return t.titleTypes.manhwa;
      case TitleType.manhua:
        return t.titleTypes.manhua;
      case TitleType.comics:
        return t.titleTypes.comics;
      case TitleType.webtoon:
        return t.titleTypes.webtoon;
      case TitleType.other:
        return t.titleTypes.other;
    }
  }
}

class TitleTypeConverter implements JsonConverter<TitleType, String> {
  const TitleTypeConverter();

  @override
  TitleType fromJson(String json) => TitleType.fromString(json);

  @override
  String toJson(TitleType object) => object.value;
}
