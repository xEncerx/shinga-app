import 'package:freezed_annotation/freezed_annotation.dart';

part 'pagination_items.freezed.dart';
part 'pagination_items.g.dart';

@freezed
abstract class PaginationItems with _$PaginationItems{
  @JsonSerializable(fieldRename: FieldRename.snake)
  const factory PaginationItems({
    required int count,
    required int total,
    required int perPage,
  }) = _PaginationItems;

  factory PaginationItems.fromJson(Map<String, dynamic> json) =>
      _$PaginationItemsFromJson(json);

  static const empty = PaginationItems(
    count: 0,
    total: 0,
    perPage: 0,
  );
}
