import 'package:shinga/domain/domain.dart';
import 'package:shinga/i18n/i18n.dart';
import 'package:shinga/i18n/strings.g.dart';

/// Extension on [TitleEntity] to provide internationalized name retrieval.
extension TitleNameI18n on TitleEntity {
  /// Returns the title's name based on the provided [AppLanguage].
  String get name {
    return switch (t.language) {
      AppLanguage.ru => nameRu ?? nameEn ?? '???',
      AppLanguage.en => nameEn ?? nameRu ?? '???',
      _ => nameEn ?? nameRu ?? '???',
    };
  }
}
