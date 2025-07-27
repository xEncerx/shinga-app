import 'package:freezed_annotation/freezed_annotation.dart';

part 'description.freezed.dart';
part 'description.g.dart';

@freezed
abstract class DescriptionData with _$DescriptionData{
  /// Represents the description of a title in different languages.
  /// - `ru` - Description in Russian.
  /// - `en` - Description in English.
  const factory DescriptionData({
    String? ru,
    String? en,
  }) = _DescriptionData;

  factory DescriptionData.fromJson(Map<String, dynamic> json) =>
      _$DescriptionDataFromJson(json);
}
