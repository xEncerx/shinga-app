part of '../app_database.dart';

/// Provides ordered and bounded access to title search history.
@DriftAccessor(tables: [TitleSearchHistoryTable])
final class TitleSearchHistoryDao extends DatabaseAccessor<AppDatabase>
    with _$TitleSearchHistoryDaoMixin {
  /// Creates a DAO attached to its database.
  TitleSearchHistoryDao(super.attachedDatabase);

  /// Returns all history rows from newest to oldest.
  Future<List<TitleSearchHistoryRow>> getHistory() => _orderedHistoryQuery().get();

  /// Upserts an item and trims old rows atomically when [maxItems] is set.
  Future<void> saveItem(
    TitleSearchHistoryTableCompanion item, {
    int? maxItems,
  }) {
    return transaction(() async {
      await into(titleSearchHistoryTable).insertOnConflictUpdate(item);
      if (maxItems == null) return;

      final retainedRows = await (_orderedHistoryQuery()..limit(maxItems)).get();
      final retainedQueries = retainedRows.map((row) => row.query).toList();

      if (retainedQueries.isEmpty) {
        await delete(titleSearchHistoryTable).go();
      } else {
        await (delete(
          titleSearchHistoryTable,
        )..where((row) => row.query.isNotIn(retainedQueries))).go();
      }
    });
  }

  /// Deletes the exact query if present.
  Future<void> deleteItem(String query) =>
      (delete(titleSearchHistoryTable)..where((row) => row.query.equals(query))).go();

  /// Deletes every history row.
  Future<void> clear() => delete(titleSearchHistoryTable).go();

  SimpleSelectStatement<$TitleSearchHistoryTableTable, TitleSearchHistoryRow>
  _orderedHistoryQuery() {
    return select(titleSearchHistoryTable)..orderBy([
      (row) => OrderingTerm.desc(row.searchedAt),
      (row) => OrderingTerm.asc(row.query),
    ]);
  }
}
