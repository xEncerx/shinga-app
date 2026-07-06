import 'package:shinga/domain/domain.dart';
import 'package:shinga/i18n/strings.g.dart';

/// An extension on [Translations] to get the current app language.
extension CurrentLanguage on Translations {
  /// Gets the current app language based on the current locale.
  AppLanguage get language => switch ($meta.locale) {
    AppLocale.en => AppLanguage.en,
    AppLocale.ru => AppLanguage.ru,
  };
}
