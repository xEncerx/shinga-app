import 'package:freezed_annotation/freezed_annotation.dart';

import 'pagination_items.dart';

part 'pagination.freezed.dart';
part 'pagination.g.dart';

@freezed
abstract class Pagination with _$Pagination {
  @JsonSerializable(fieldRename: FieldRename.snake)
  const factory Pagination({
    required int lastVisiblePage,
    required bool hasNextPage,
    required int currentPage,
    required PaginationItems items,
  }) = _Pagination;

  factory Pagination.fromJson(Map<String, dynamic> json) => _$PaginationFromJson(json);

  static const empty = Pagination(
    lastVisiblePage: 0,
    hasNextPage: false,
    currentPage: 0,
    items: PaginationItems.empty,
  );
}
