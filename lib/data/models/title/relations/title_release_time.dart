import 'package:freezed_annotation/freezed_annotation.dart';

part 'title_release_time.freezed.dart';
part 'title_release_time.g.dart';

@freezed
abstract class TitleReleaseTime with _$TitleReleaseTime {
  /// Represents the release time of a title.
  /// - `from` - The start date and time of the release.
  /// - `to` - The end date and time of the release.
  @JsonSerializable(fieldRename: FieldRename.snake)
  const factory TitleReleaseTime({
    @JsonKey(name: 'from_') @DateTimeConverter() DateTime? from,
    @DateTimeConverter() DateTime? to,
  }) = _TitleReleaseTime;

  factory TitleReleaseTime.fromJson(Map<String, dynamic> json) =>
      _$TitleReleaseTimeFromJson(json);
}

class DateTimeConverter implements JsonConverter<DateTime?, String?> {
  const DateTimeConverter();

  @override
  DateTime? fromJson(String? json) {
    if (json == null) return null;
    return DateTime.tryParse(json);
  }

  @override
  String? toJson(DateTime? object) {
    return object?.toIso8601String();
  }
}
