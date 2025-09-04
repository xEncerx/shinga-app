import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../data.dart';

part 'titles_filter_fields.freezed.dart';
part 'titles_filter_fields.g.dart';

@freezed
abstract class TitlesFilterFields with _$TitlesFilterFields {
  @JsonSerializable(fieldRename: FieldRename.snake)
  const factory TitlesFilterFields({
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
    @BookMarkTypeConverter() BookMarkType? bookmark,
  }) = _TitlesFilterFields;

  factory TitlesFilterFields.fromJson(Map<String, dynamic> json) =>
      _$TitlesFilterFieldsFromJson(json);
}

extension TitlesFilterFieldsExtension on TitlesFilterFields {
  /// Gets the form values for the filter fields.
  Map<String, dynamic> toFormValues() {
    return {
      'type_': type ?? [],
      'genres': genres ?? [],
      'status': status ?? [],
      'min_rating': minRating?.toString() ?? '',
      'max_rating': maxRating?.toString() ?? '',
      'min_chapters': minChapters?.toString() ?? '',
      'max_chapters': maxChapters?.toString() ?? '',
      'sort_by': sortBy,
      'sort_order': sortOrder,
      'bookmark': bookmark,
    };
  }
}
