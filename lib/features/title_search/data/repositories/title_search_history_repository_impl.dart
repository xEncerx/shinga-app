import 'package:fpdart/fpdart.dart';
import 'package:shinga/data/data.dart';
import 'package:shinga/domain/domain.dart';
import 'package:shinga/features/title_search/title_search.dart';
import 'package:storage/storage.dart';

/// Implementation of [TitleSearchHistoryRepository] using local storage.
class TitleSearchHistoryRepositoryImpl implements TitleSearchHistoryRepository {
  /// Creates a [TitleSearchHistoryRepositoryImpl] instance.
  const TitleSearchHistoryRepositoryImpl(this._storage);

  /// The storage used for persisting search history.
  final CollectionStorage<TitleSearchHistoryItemDTO> _storage;

  @override
  Future<Either<AppFailure, List<TitleSearchHistoryItem>>> getHistory() async {
    return ExceptionMapper.guard(() async {
      final items = await _storage.readAll();
      items.sort((a, b) => b.timestamp.compareTo(a.timestamp));

      return items.map((dto) => dto.toDomain()).toList();
    });
  }

  @override
  Future<Either<AppFailure, Unit>> addItem(TitleSearchHistoryItem item, {int? maxItems}) async {
    final historyItem = TitleSearchHistoryItemDTO.fromDomain(item);

    return ExceptionMapper.guard(() async {
      await _storage.write(
        historyItem.query,
        historyItem,
      );

      if (maxItems != null) {
        await _removeOldestItems(maxItems);
      }

      return unit;
    });
  }

  @override
  Future<Either<AppFailure, Unit>> removeItem(TitleSearchHistoryItem item) async {
    final historyItem = TitleSearchHistoryItemDTO.fromDomain(item);

    return ExceptionMapper.guard(() async {
      await _storage.delete(historyItem.query);

      return unit;
    });
  }

  @override
  Future<Either<AppFailure, Unit>> clear() async {
    return ExceptionMapper.guard(() async {
      await _storage.clear();

      return unit;
    });
  }

  Future<void> _removeOldestItems(int maxItems) async {
    final items = await _storage.readAll();
    if (items.length <= maxItems) return;

    items.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    final itemsToRemove = items.skip(maxItems);
    for (final item in itemsToRemove) {
      await _storage.delete(item.query);
    }
  }
}
