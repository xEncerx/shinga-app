import '../../../data/data.dart';

class SearchHistoryRepository {
  SearchHistoryRepository(this._hiveDatasource);

  final HiveDatasource _hiveDatasource;

  List<String?> getSearchHistory() {
    final data = _hiveDatasource.searchHistoryBox.values.toList();

    data.sort((a, b) => b.timestamp.compareTo(a.timestamp));

    return data.map((item) => item.query).toList();
  }

  Future<void> addToSearchHistory({required String value}) async {
    if (value.trim().isEmpty) return;

    // TODO: History should be limited to 50 items

    final data = _hiveDatasource.searchHistoryBox.values;

    SearchHistoryItem? item;
    try {
      item = data.firstWhere((item) => item.query == value);
    } catch (_) {
      item = null;
    }

    if (item != null) {
      item.timestamp = DateTime.now();
      await item.save();
    } else {
      await _hiveDatasource.searchHistoryBox.add(
        SearchHistoryItem(query: value),
      );
    }
  }

  Future<void> clearSearchHistory() async {
    await _hiveDatasource.searchHistoryBox.clear();
  }
}
