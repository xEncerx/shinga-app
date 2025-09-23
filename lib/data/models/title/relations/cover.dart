import 'package:freezed_annotation/freezed_annotation.dart';

part 'cover.freezed.dart';
part 'cover.g.dart';

@freezed
abstract class CoverData with _$CoverData {
  /// Represents cover data for a title.
  /// - `url` - Path of the basic version of the cover image.
  /// - `smallUrl` - Path of the small version of the cover image.
  /// - `largeUrl` - Path of the large version of the cover image.
  @JsonSerializable(fieldRename: FieldRename.snake)
  const factory CoverData({
    String? url,
    String? smallUrl,
    String? largeUrl,
  }) = _CoverData;

  factory CoverData.fromJson(Map<String, dynamic> json) => _$CoverDataFromJson(json);
}
