import 'package:shinga/domain/domain.dart';
import 'package:shinga/i18n/i18n.dart';
import 'package:shinga/i18n/strings.g.dart';

/// Extension on [TitleGenre] to resolve its localized string representation.
extension TitleGenreI18n on TitleGenre {
  /// Returns the localized string corresponding to this [TitleGenre] value.
  String get i18n => switch (t.language) {
    AppLanguage.ru => ru,
    AppLanguage.en => en,
    _ => en,
  };
}
