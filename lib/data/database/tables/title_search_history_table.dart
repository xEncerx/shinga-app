part of '../app_database.dart';

/// Stores unique title search queries and their latest usage time.
@DataClassName('TitleSearchHistoryRow')
@TableIndex(
  name: 'title_search_history_searched_at',
  columns: {#searchedAt},
)
class TitleSearchHistoryTable extends Table {
  /// The exact, case-sensitive search query.
  TextColumn get query => text()();

  /// The latest time at which the query was used.
  DateTimeColumn get searchedAt => dateTime()();

  @override
  String get tableName => 'title_search_history';

  @override
  Set<Column<Object>> get primaryKey => {query};
}
