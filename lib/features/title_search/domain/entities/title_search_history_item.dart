import 'package:freezed_annotation/freezed_annotation.dart';

part 'title_search_history_item.freezed.dart';

/// A record of a past title search query.
@freezed
abstract class TitleSearchHistoryItem with _$TitleSearchHistoryItem {
  /// Creates a [TitleSearchHistoryItem] instance.
  const factory TitleSearchHistoryItem({
    /// The search query string.
    required String query,

    /// The time at which the search was performed.
    required DateTime timestamp,
  }) = _TitleSearchHistoryItem;
}
