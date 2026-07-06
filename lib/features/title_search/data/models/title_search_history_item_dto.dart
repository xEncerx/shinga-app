import 'package:shinga/features/title_search/domain/domain.dart';

/// Data transfer object for a search history item.
class TitleSearchHistoryItemDTO {
  /// Creates a [TitleSearchHistoryItemDTO] instance.
  TitleSearchHistoryItemDTO({
    required this.query,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  /// Creates a [TitleSearchHistoryItemDTO] from a domain [TitleSearchHistoryItem].
  TitleSearchHistoryItemDTO.fromDomain(TitleSearchHistoryItem item)
    : query = item.query,
      timestamp = item.timestamp;

  /// The search query text.
  final String query;

  /// The timestamp when the search was performed.
  final DateTime timestamp;

  /// Converts this DTO to a domain [TitleSearchHistoryItem].
  TitleSearchHistoryItem toDomain() => TitleSearchHistoryItem(
    query: query,
    timestamp: timestamp,
  );
}
