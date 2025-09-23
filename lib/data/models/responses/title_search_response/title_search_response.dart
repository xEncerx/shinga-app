import 'package:freezed_annotation/freezed_annotation.dart';

import '../title_with_user_data/title_with_user_data.dart';

part 'title_search_response.freezed.dart';
part 'title_search_response.g.dart';

@freezed
abstract class TitleSearchResponse with _$TitleSearchResponse {
  const factory TitleSearchResponse({
    required String message,
    required List<TitleWithUserData> content,
  }) = _TitleSearchResponse;

  factory TitleSearchResponse.fromJson(Map<String, dynamic> json) =>
      _$TitleSearchResponseFromJson(json);
}
