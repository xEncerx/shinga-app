import 'package:shinga/domain/domain.dart';
import 'package:shinga/i18n/strings.g.dart';

/// Extension on [AppLanguage] to resolve its localized string representation.
extension AppLanguageI18n on AppLanguage {
  /// Returns the localized string corresponding to this [AppLanguage].
  String get i18n => switch (this) {
    AppLanguage.ru => t.settings.language.values.ru,
    AppLanguage.en => t.settings.language.values.en,
    AppLanguage.system => t.settings.language.values.system,
  };
}
