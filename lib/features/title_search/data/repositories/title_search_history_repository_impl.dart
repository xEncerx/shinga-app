import 'package:fpdart/fpdart.dart';
import 'package:shinga/data/data.dart';
import 'package:shinga/domain/domain.dart';
import 'package:shinga/features/title_search/title_search.dart';

/// Implements [TitleSearchHistoryRepository] with a bounded Drift table.
class TitleSearchHistoryRepositoryImpl implements TitleSearchHistoryRepository {
  /// Creates a [TitleSearchHistoryRepositoryImpl] instance.
  const TitleSearchHistoryRepositoryImpl(this._dao);

  final TitleSearchHistoryDao _dao;

  @override
  Future<Either<AppFailure, List<TitleSearchHistoryItem>>> getHistory() async {
    return ExceptionMapper.guard(() async {
      final rows = await StorageExceptionGuard.read(_dao.getHistory);
      return rows.map((row) => row.toDomain()).toList();
    });
  }

  @override
  Future<Either<AppFailure, Unit>> addItem(TitleSearchHistoryItem item, {int? maxItems}) async {
    return ExceptionMapper.guard(() async {
      await StorageExceptionGuard.write(
        () => _dao.saveItem(
          TitleSearchHistoryTableCompanion.insert(
            query: item.query,
            searchedAt: item.timestamp,
          ),
          maxItems: maxItems,
        ),
      );
      return unit;
    });
  }

  @override
  Future<Either<AppFailure, Unit>> removeItem(TitleSearchHistoryItem item) async {
    return ExceptionMapper.guard(() async {
      await StorageExceptionGuard.delete(() => _dao.deleteItem(item.query));
      return unit;
    });
  }

  @override
  Future<Either<AppFailure, Unit>> clear() async {
    return ExceptionMapper.guard(() async {
      await StorageExceptionGuard.delete(_dao.clear);
      return unit;
    });
  }
}

extension on TitleSearchHistoryRow {
  TitleSearchHistoryItem toDomain() => TitleSearchHistoryItem(
    query: query,
    timestamp: searchedAt,
  );
}
