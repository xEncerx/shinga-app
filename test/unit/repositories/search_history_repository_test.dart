import 'package:flutter_test/flutter_test.dart';
import 'package:hive_ce/hive.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:shinga/data/models/search_history_item.dart';
import 'package:shinga/data/repositories/search_history_repository.dart';

@GenerateMocks([Box])
import 'search_history_repository_test.mocks.dart';

void main() {
  group('SearchHistoryRepository', () {
    late MockBox<SearchHistoryItem> mockBox;
    late SearchHistoryRepository repository;

    setUp(() {
      mockBox = MockBox<SearchHistoryItem>();
      repository = SearchHistoryRepository(mockBox);
    });

    // ==================== addToSearchHistory() ====================
    group('addToSearchHistory()', () {
      test('should add new search query to history', () async {
        const searchQuery = 'testValue';

        when(mockBox.values).thenReturn([]);
        when(mockBox.add(any)).thenAnswer((_) async => 0);

        await repository.addToSearchHistory(searchQuery);

        final captured = verify(mockBox.add(captureAny)).captured;
        expect(captured.length, equals(1));

        final addedItem = captured.first as SearchHistoryItem;
        expect(addedItem.query, equals(searchQuery));
        expect(addedItem.timestamp, isNotNull);
      });
      test('should not add empty or whitespace-only queries', () async {
        const emptyQuery = '';
        const whitespaceQuery = '   ';

        await repository.addToSearchHistory(emptyQuery);
        await repository.addToSearchHistory(whitespaceQuery);

        verifyNever(mockBox.add(any));
      });
    });
    // ==================== getSearchHistory() ====================
    group('getSearchHistory()', () {
      test('should return queries sorted by timestamp descending', () {
        final items = [
          SearchHistoryItem(query: 'old')..timestamp = DateTime(2024),
          SearchHistoryItem(query: 'new')..timestamp = DateTime(2024, 12, 31),
          SearchHistoryItem(query: 'middle')..timestamp = DateTime(2024, 6, 15),
        ];
        when(mockBox.values).thenReturn(items);

        final result = repository.getSearchHistory();

        expect(result, equals(['new', 'middle', 'old']));
      });
    });
    // ==================== clearSearchHistory() ====================
    group('clearSearchHistory()', () {
      test('should clear all items from history', () async {
        when(mockBox.clear()).thenAnswer((_) async => 0);

        await repository.clearSearchHistory();

        verify(mockBox.clear()).called(1);
      });
    });
  });
}
