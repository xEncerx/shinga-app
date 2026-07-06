/// Metadata about the content within a paginated response.
class PaginatedContentMetadata {
  /// Creates a [PaginatedContentMetadata] instance.
  PaginatedContentMetadata({
    required this.count,
    required this.total,
    required this.perPage,
  });

  /// The number of items in the current page.
  final int count;

  /// The total number of items across all pages.
  final int total;

  /// The maximum number of items returned per page.
  final int perPage;
}

/// Pagination information for a paginated API response.
class PaginationDetail {
  /// Creates a [PaginationDetail] instance.
  PaginationDetail({
    required this.lastVisiblePage,
    required this.hasNextPage,
    required this.currentPage,
    required this.metadata,
  });

  /// The index of the last visible page.
  final int lastVisiblePage;

  /// Whether there is a subsequent page available.
  final bool hasNextPage;

  /// The index of the currently requested page.
  final int currentPage;

  /// Content metadata for the current page.
  final PaginatedContentMetadata metadata;
}
