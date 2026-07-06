import 'package:fpdart/fpdart.dart';
import 'package:shinga/domain/domain.dart';
import 'package:shinga/features/title_search/domain/domain.dart';

/// Repository for managing title search history.
abstract class TitleSearchHistoryRepository {
  /// Retrieves the list of title search history items.
  Future<Either<AppFailure, List<TitleSearchHistoryItem>>> getHistory();

  /// Adds a new item to the title search history.
  ///
  /// If [maxItems] is provided, the history will be trimmed to keep only the most recent [maxItems] entries.
  Future<Either<AppFailure, Unit>> addItem(TitleSearchHistoryItem item, {int? maxItems});

  /// Removes a specific item from the title search history.
  Future<Either<AppFailure, Unit>> removeItem(TitleSearchHistoryItem item);

  /// Clears all items from the title search history.
  Future<Either<AppFailure, Unit>> clear();
}
