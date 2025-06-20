import 'package:hive_ce/hive.dart';

class SearchHistoryItem extends HiveObject{
  /// Represents an item in the search history.
  /// - `query`: The search query string.
  /// - `timestamp`: The time when the search was performed.
  SearchHistoryItem({
    this.query = "",
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  String query = "";
  DateTime timestamp;
}
