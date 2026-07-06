import 'package:shinga/domain/domain.dart';
import 'package:shinga/i18n/i18n.dart';
import 'package:shinga/i18n/strings.g.dart';

/// Extension on [TitleEntity] to resolve its localized string representation.
extension TitleDescriptionI18n on TitleEntity {
  /// Returns the localized string corresponding to this [TitleEntity] description.
  String get description {
    if (t.language == AppLanguage.ru && descriptionRu != null) {
      return descriptionRu!;
    } else if (t.language == AppLanguage.en && descriptionEn != null) {
      return descriptionEn!;
    } else {
      return t.titleDetail.description.emptyDescription;
    }
  }
}
