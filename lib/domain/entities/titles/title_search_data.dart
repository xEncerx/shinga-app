import 'package:shinga/domain/domain.dart';

/// Domain entity representing a paginated title search result.
class TitleSearchData {
  /// Creates a [TitleSearchData] instance.
  TitleSearchData({
    required this.pagination,
    required this.content,
  });

  /// Pagination details for the current search result page.
  final PaginationDetail pagination;

  /// The list of titles returned by the search on the current page.
  final List<TitleWithUserDataEntity> content;
}
