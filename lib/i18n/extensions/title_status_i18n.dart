import 'package:shinga/domain/domain.dart';
import 'package:shinga/i18n/strings.g.dart';

/// Extension on [TitleStatus] to provide internationalized strings.
extension TitleStatusI18n on TitleStatus {
  /// Returns the internationalized string corresponding to this [TitleStatus].
  String get i18n => switch (this) {
    TitleStatus.ongoing => t.titles.statuses.ongoing,
    TitleStatus.finished => t.titles.statuses.finished,
    TitleStatus.discontinued => t.titles.statuses.discontinued,
    TitleStatus.frozen => t.titles.statuses.frozen,
    TitleStatus.anons => t.titles.statuses.anons,
    TitleStatus.unknown => t.titles.statuses.unknown,
  };
}
