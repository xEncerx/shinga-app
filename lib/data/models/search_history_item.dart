import 'package:hive_ce/hive.dart';

class SearchHistoryItem extends HiveObject{
  SearchHistoryItem({
    this.query = "",
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  String query = "";
  DateTime timestamp;
}
