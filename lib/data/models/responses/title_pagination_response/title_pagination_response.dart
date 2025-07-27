import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../data.dart';

part 'title_pagination_response.freezed.dart';
part 'title_pagination_response.g.dart';

@freezed
abstract class TitlePaginationResponse with _$TitlePaginationResponse{
  const factory TitlePaginationResponse({
    required String message,
    required Pagination pagination,
    required List<TitleWithUserData> content,
  }) = _TitlePaginationResponse;

  factory TitlePaginationResponse.fromJson(Map<String, dynamic> json) =>
      _$TitlePaginationResponseFromJson(json);
}
