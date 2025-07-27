import 'package:hive_ce/hive.dart';

import '../../../data/data.dart';

/// Repository for managing search history
class SearchHistoryRepository {
  /// Creates an instance of [SearchHistoryRepository] with the provided Hive box
  /// 
  /// The [searchHistoryBox] is expected to be a Hive box containing [SearchHistoryItem] objects.
  SearchHistoryRepository(this._searchHistoryBox);

  final Box<SearchHistoryItem> _searchHistoryBox;

  /// Returns a list of search queries sorted by timestamp in descending order
  List<String> getSearchHistory() {
    final data = _searchHistoryBox.values.toList();

    data.sort((a, b) => b.timestamp.compareTo(a.timestamp));

    return data.map((item) => item.query).toList();
  }

  /// Adds a new search query to the search history
  /// If the query already exists, it updates the timestamp
  Future<void> addToSearchHistory(String value) async {
    if (value.trim().isEmpty) return;

    final historyValues = _searchHistoryBox.values;

    SearchHistoryItem? item;
    try {
      item = historyValues.firstWhere((item) => item.query == value);
    } catch (_) {}

    if (item != null) {
      item.timestamp = DateTime.now();
      await item.save();
      // Create a new item if it doesn't exist
    } else {
      await _searchHistoryBox.add(
        SearchHistoryItem(query: value),
      );
      // Remove the oldest item if the history exceeds 50 items
      if (historyValues.length > 50) {
        final oldestItem = historyValues.reduce(
          (a, b) => a.timestamp.isBefore(b.timestamp) ? a : b,
        );
        await oldestItem.delete();
      }
    }
  }

  /// Clears the search history
  Future<void> clearSearchHistory() async {
    await _searchHistoryBox.clear();
  }
}
