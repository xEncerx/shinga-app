import 'package:json_annotation/json_annotation.dart';

import '../../../../i18n/strings.g.dart';

enum TitleStatus {
  ongoing('ongoing'),
  finished('finished'),
  discontinued('discontinued'),
  licensed('licensed'),
  frozen('frozen'),
  anons('anons'),
  unknown('unknown');

  const TitleStatus(this.value);
  final String value;

  static TitleStatus fromString(String value) {
    return values.firstWhere(
      (e) => e.value == value,
      orElse: () => TitleStatus.unknown, // fallback
    );
  }

  /// Returns the internationalized string for the title status.
  String get i18n {
    switch (this) {
      case TitleStatus.ongoing:
        return t.titleStatuses.ongoing;
      case TitleStatus.finished:
        return t.titleStatuses.finished;
      case TitleStatus.discontinued:
        return t.titleStatuses.discontinued;
      case TitleStatus.licensed:
        return t.titleStatuses.licensed;
      case TitleStatus.frozen:
        return t.titleStatuses.frozen;
      case TitleStatus.anons:
        return t.titleStatuses.anons;
      case TitleStatus.unknown:
        return t.titleStatuses.unknown;
    }
  }
}

class TitleStatusConverter implements JsonConverter<TitleStatus, String> {
  const TitleStatusConverter();

  @override
  TitleStatus fromJson(String json) => TitleStatus.fromString(json);

  @override
  String toJson(TitleStatus object) => object.value;
}
