import 'package:shinga/domain/domain.dart';
import 'package:shinga/i18n/strings.g.dart';

/// Extension on [TitleReadModeI18n] to resolve its localized string representation.
extension TitleReadModeI18n on TitleReadMode {
  /// Returns the localized string corresponding to this [TitleReadModeI18n] value.
  String get i18n => switch (this) {
    TitleReadMode.webView => t.settings.reader.readMode.values.webView,
    TitleReadMode.externalBrowser => t.settings.reader.readMode.values.externalBrowser,
  };
}
