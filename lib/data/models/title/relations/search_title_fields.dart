import 'package:freezed_annotation/freezed_annotation.dart';

part 'search_title_fields.freezed.dart';
part 'search_title_fields.g.dart';

@freezed
abstract class SearchTitleFields with _$SearchTitleFields{
  @JsonSerializable(fieldRename: FieldRename.snake)
  const factory SearchTitleFields({
    String? query,
    List<String>? genres,
    List<String>? status,
    @JsonKey(name: 'type_') List<String>? type,
    double? minRating,
    double? maxRating,
    int? minChapters,
    int? maxChapters,
    String? sortBy,
    String? sortOrder,
    int? page,
    int? perPage,
  }) = _SearchTitleFields;

  factory SearchTitleFields.fromJson(Map<String, dynamic> json) =>
      _$SearchTitleFieldsFromJson(json);
}
