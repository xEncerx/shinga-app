import 'package:shinga/core/types/types.dart';
import 'package:shinga/data/data.dart';
import 'package:shinga/domain/domain.dart';
import 'package:shinga/features/title_search/title_search.dart';

/// Implements [TitleSearchHistoryRepository] with a bounded Drift table.
class TitleSearchHistoryRepositoryImpl implements TitleSearchHistoryRepository {
  /// Creates a [TitleSearchHistoryRepositoryImpl] instance.
  const TitleSearchHistoryRepositoryImpl(this._dao);

  final TitleSearchHistoryDao _dao;

  @override
  Future<Either<AppFailure, List<TitleSearchHistoryItem>>> getHistory() {
    return ExceptionMapper.guard(() async {
      final rows = await StorageExceptionGuard.read(_dao.getHistory);
      return rows.map((row) => row.toDomain()).toList();
    });
  }

  @override
  Future<Either<AppFailure, void>> addItem(TitleSearchHistoryItem item, {int? maxItems}) {
    return ExceptionMapper.guardVoid(() async {
      await StorageExceptionGuard.write(
        () => _dao.saveItem(
          TitleSearchHistoryTableCompanion.insert(
            query: item.query,
            searchedAt: item.timestamp,
          ),
          maxItems: maxItems,
        ),
      );
    });
  }

  @override
  Future<Either<AppFailure, void>> removeItem(TitleSearchHistoryItem item) {
    return ExceptionMapper.guardVoid(() async {
      await StorageExceptionGuard.delete(() => _dao.deleteItem(item.query));
    });
  }

  @override
  Future<Either<AppFailure, void>> clear() {
    return ExceptionMapper.guardVoid(() async {
      await StorageExceptionGuard.delete(_dao.clear);
    });
  }
}

extension on TitleSearchHistoryRow {
  TitleSearchHistoryItem toDomain() => TitleSearchHistoryItem(
    query: query,
    timestamp: searchedAt,
  );
}
