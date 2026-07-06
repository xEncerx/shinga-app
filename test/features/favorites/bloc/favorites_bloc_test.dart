import 'package:bloc_test/bloc_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shinga/core/core.dart';
import 'package:shinga/domain/domain.dart';
import 'package:shinga/features/features.dart';
import 'package:test/test.dart';

class MockTitleRepository extends Mock implements TitleRepository {}

/// Test file
// ignore_for_file: avoid_redundant_argument_values

TitleEntity _makeTitle(int id) => TitleEntity(
  id: id,
  altNames: const [],
  type: TitleType.manga,
  status: TitleStatus.ongoing,
  popularity: 0,
  chapters: 0,
  views: 0,
  volumes: 0,
  favorites: 0,
  rating: 0,
  scoredBy: 0,
  releasedAt: null,
  endedAt: null,
  genres: const [],
  categories: const [],
  authors: const [],
  cover: const TitleCoverEntity(original: '', thumbnail: ''),
);

UserTitleDataEntity _makeUserData(
  Bookmark bookmark, {
  double rating = 0,
  bool isFavorite = false,
  String? note,
}) => UserTitleDataEntity(
  rating: rating,
  bookmark: bookmark,
  isFavorite: isFavorite,
  note: note,
);

TitleWithUserDataEntity _makeEntity(
  int id,
  Bookmark bookmark, {
  double rating = 0,
  bool isFavorite = false,
  String? note,
}) => TitleWithUserDataEntity(
  title: _makeTitle(id),
  userData: _makeUserData(bookmark, rating: rating, isFavorite: isFavorite, note: note),
);

TitleSearchData _makeSearchData(
  List<TitleWithUserDataEntity> items, {
  bool hasNextPage = false,
  int currentPage = 1,
}) => TitleSearchData(
  pagination: PaginationDetail(
    lastVisiblePage: 1,
    hasNextPage: hasNextPage,
    currentPage: currentPage,
    metadata: PaginatedContentMetadata(
      count: items.length,
      total: items.length,
      perPage: 10,
    ),
  ),
  content: items,
);

/// Returns the expected [FavoritesState] after loading [items] as page 1 of
/// [bookmark]. Stacks on top of [base] so previous bookmarks are preserved.
FavoritesState _loadedState(
  FavoritesState base,
  Bookmark bookmark,
  List<TitleWithUserDataEntity> items, {
  bool hasNextPage = false,
}) => base.withPagingState(
  bookmark,
  PagingState(
    pages: [items],
    keys: const [1],
    hasNextPage: hasNextPage,
    isLoading: false,
  ),
);

/// Returns the loading intermediate [FavoritesState] for [bookmark] stacked on [base].
FavoritesState _loadingState(FavoritesState base, Bookmark bookmark) =>
    base.withPagingState(bookmark, PagingState(isLoading: true));

/// Stubs repo.searchTitles to return [data] when called with [bookmark] and
/// [page]. Any filter is accepted.
void _stubFetch(
  MockTitleRepository repo,
  Bookmark bookmark,
  int page,
  TitleSearchData data,
) {
  when(
    () => repo.searchTitles(
      bookmark: bookmark,
      filter: any(named: 'filter'),
      page: page,
    ),
  ).thenAnswer((_) async => Right(data));
}

void main() {
  late MockTitleRepository repo;

  setUp(() {
    repo = MockTitleRepository();
    registerFallbackValue(TitleFilter.empty);
    registerFallbackValue(Bookmark.reading);
  });

  group('FavoritesBloc —', () {
    group('1. Move to top on update (same bookmark)', () {
      final t1 = _makeEntity(1, Bookmark.reading);
      final t2 = _makeEntity(2, Bookmark.reading);
      final t3 = _makeEntity(3, Bookmark.reading);
      final t2Updated = _makeEntity(2, Bookmark.reading, rating: 9.5, note: 'great');

      final pageData = _makeSearchData([t1, t2, t3]);

      blocTest<FavoritesBloc, FavoritesState>(
        'removes matching item and prepends it to the top of the list',
        build: () => FavoritesBloc(repo),
        setUp: () => _stubFetch(repo, Bookmark.reading, 1, pageData),
        act: (bloc) async {
          bloc.add(FavoritesFetchNextPage(Bookmark.reading));
          await Future<void>.delayed(const Duration(milliseconds: 350));
          TitleUpdateBus.instance.emit(t2Updated);
        },
        wait: const Duration(milliseconds: 100),
        verify: (bloc) {
          final items = bloc.state.pagingStateFor(Bookmark.reading).items;

          // Original list was [t1, t2, t3]. Wait, after load it was [t1, t2, t3].
          // When updated t2, it is filtered out and prepended.
          // Expected is [t2Updated, t1, t3]
          expect(items?.length, 3);
          expect(items?.map((e) => e.title.id), [2, 1, 3]);
          expect(items?.first.userData?.rating, 9.5);
        },
      );

      blocTest<FavoritesBloc, FavoritesState>(
        'emitting exactly same entity instance skips state re-emission (equality guard)',
        build: () => FavoritesBloc(repo),
        setUp: () => _stubFetch(repo, Bookmark.reading, 1, pageData),
        act: (bloc) async {
          bloc.add(FavoritesFetchNextPage(Bookmark.reading));
          await Future<void>.delayed(const Duration(milliseconds: 350));

          // We wait to make sure we measure states starting now
          TitleUpdateBus.instance.emit(t1);
        },
        wait: const Duration(milliseconds: 100),
        // Only 2 states should have been emitted in total (loading + initial loaded)
        // No new state emission should happen after TitleUpdateBus
        expect: () {
          return [
            _loadingState(const FavoritesState(), Bookmark.reading),
            _loadedState(const FavoritesState(), Bookmark.reading, [t1, t2, t3]),
          ];
        },
      );
    });

    group('2. Transfer between bookmarks (single page each)', () {
      final t1 = _makeEntity(1, Bookmark.reading);
      final t2 = _makeEntity(2, Bookmark.reading);
      final t3 = _makeEntity(3, Bookmark.planning);
      final t4 = _makeEntity(4, Bookmark.planning);
      // t2 changes bookmark to planning
      final t2Transferred = _makeEntity(2, Bookmark.planning);

      blocTest<FavoritesBloc, FavoritesState>(
        'removes from old bookmark, prepends to new bookmark',
        build: () => FavoritesBloc(repo),
        setUp: () {
          _stubFetch(repo, Bookmark.reading, 1, _makeSearchData([t1, t2]));
          _stubFetch(repo, Bookmark.planning, 1, _makeSearchData([t3, t4]));
        },
        act: (bloc) async {
          bloc.add(FavoritesFetchNextPage(Bookmark.reading));
          await Future<void>.delayed(const Duration(milliseconds: 350));
          bloc.add(FavoritesFetchNextPage(Bookmark.planning));
          await Future<void>.delayed(const Duration(milliseconds: 350));
          TitleUpdateBus.instance.emit(t2Transferred);
        },
        wait: const Duration(milliseconds: 100),
        verify: (bloc) {
          final readingItems = bloc.state.pagingStateFor(Bookmark.reading).items;
          final planningItems = bloc.state.pagingStateFor(Bookmark.planning).items;

          expect(readingItems?.map((e) => e.title.id), [1]);
          expect(planningItems?.first.title.id, 2);
          expect(planningItems?.first.userData!.bookmark, Bookmark.planning);
          expect(planningItems?.map((e) => e.title.id), [2, 3, 4]);
        },
      );

      blocTest<FavoritesBloc, FavoritesState>(
        'transferred item carries updated userData, not original',
        build: () => FavoritesBloc(repo),
        setUp: () {
          _stubFetch(repo, Bookmark.reading, 1, _makeSearchData([t1, t2]));
          _stubFetch(repo, Bookmark.planning, 1, _makeSearchData([t3]));
        },
        act: (bloc) async {
          bloc.add(FavoritesFetchNextPage(Bookmark.reading));
          await Future<void>.delayed(const Duration(milliseconds: 350));
          bloc.add(FavoritesFetchNextPage(Bookmark.planning));
          await Future<void>.delayed(const Duration(milliseconds: 350));
          TitleUpdateBus.instance.emit(t2Transferred);
        },
        wait: const Duration(milliseconds: 100),
        verify: (bloc) {
          final planningItems = bloc.state.pagingStateFor(Bookmark.planning).items!;
          final movedItem = planningItems.first;
          expect(movedItem.userData!.bookmark, Bookmark.planning);
        },
      );
    });

    group('3. Transfer of item on page 2 (multi-page bookmark)', () {
      final t1 = _makeEntity(1, Bookmark.reading);
      final t2 = _makeEntity(2, Bookmark.reading);
      final t3 = _makeEntity(3, Bookmark.reading); // page 2
      final t4 = _makeEntity(4, Bookmark.reading); // page 2
      final t5 = _makeEntity(5, Bookmark.planning);
      final t4Transferred = _makeEntity(4, Bookmark.planning);

      blocTest<FavoritesBloc, FavoritesState>(
        'removes from correct page, prepends to target bookmark',
        build: () => FavoritesBloc(repo),
        setUp: () {
          _stubFetch(
            repo,
            Bookmark.reading,
            1,
            _makeSearchData([t1, t2], hasNextPage: true),
          );
          _stubFetch(
            repo,
            Bookmark.reading,
            2,
            _makeSearchData([t3, t4]),
          );
          _stubFetch(repo, Bookmark.planning, 1, _makeSearchData([t5]));
        },
        act: (bloc) async {
          bloc.add(FavoritesFetchNextPage(Bookmark.reading));
          await Future<void>.delayed(const Duration(milliseconds: 350));
          bloc.add(FavoritesFetchNextPage(Bookmark.reading));
          await Future<void>.delayed(const Duration(milliseconds: 350));
          bloc.add(FavoritesFetchNextPage(Bookmark.planning));
          await Future<void>.delayed(const Duration(milliseconds: 350));
          TitleUpdateBus.instance.emit(t4Transferred);
        },
        wait: const Duration(milliseconds: 100),
        verify: (bloc) {
          final readingItems = bloc.state.pagingStateFor(Bookmark.reading).items;
          final planningItems = bloc.state.pagingStateFor(Bookmark.planning).items;

          expect(readingItems?.map((e) => e.title.id), [1, 2, 3]);
          expect(planningItems?.map((e) => e.title.id), [4, 5]);
        },
      );

      blocTest<FavoritesBloc, FavoritesState>(
        'page structure of reading is preserved (2 pages, each filtered)',
        build: () => FavoritesBloc(repo),
        setUp: () {
          _stubFetch(
            repo,
            Bookmark.reading,
            1,
            _makeSearchData([t1, t2], hasNextPage: true),
          );
          _stubFetch(
            repo,
            Bookmark.reading,
            2,
            _makeSearchData([t3, t4]),
          );
          _stubFetch(repo, Bookmark.planning, 1, _makeSearchData([t5]));
        },
        act: (bloc) async {
          bloc.add(FavoritesFetchNextPage(Bookmark.reading));
          await Future<void>.delayed(const Duration(milliseconds: 350));
          bloc.add(FavoritesFetchNextPage(Bookmark.reading));
          await Future<void>.delayed(const Duration(milliseconds: 350));
          bloc.add(FavoritesFetchNextPage(Bookmark.planning));
          await Future<void>.delayed(const Duration(milliseconds: 350));
          TitleUpdateBus.instance.emit(t4Transferred);
        },
        wait: const Duration(milliseconds: 100),
        verify: (bloc) {
          final pages = bloc.state.pagingStateFor(Bookmark.reading).pages!;
          // Page 1 unchanged, page 2 has t4 removed
          expect(pages[0].map((e) => e.title.id), [1, 2]);
          expect(pages[1].map((e) => e.title.id), [3]);
        },
      );
    });

    group('4. Transfer → update (latest data wins)', () {
      final t1 = _makeEntity(1, Bookmark.reading);
      final t2 = _makeEntity(2, Bookmark.reading);
      final t3 = _makeEntity(3, Bookmark.planning);
      final t2Transferred = _makeEntity(2, Bookmark.planning);
      final t2UpdatedAfter = _makeEntity(2, Bookmark.planning, rating: 8, note: 'updated after');

      blocTest<FavoritesBloc, FavoritesState>(
        'item in new bookmark reflects post-transfer update',
        build: () => FavoritesBloc(repo),
        setUp: () {
          _stubFetch(repo, Bookmark.reading, 1, _makeSearchData([t1, t2]));
          _stubFetch(repo, Bookmark.planning, 1, _makeSearchData([t3]));
        },
        act: (bloc) async {
          bloc.add(FavoritesFetchNextPage(Bookmark.reading));
          await Future<void>.delayed(const Duration(milliseconds: 350));
          bloc.add(FavoritesFetchNextPage(Bookmark.planning));
          await Future<void>.delayed(const Duration(milliseconds: 350));
          // Transfer
          TitleUpdateBus.instance.emit(t2Transferred);
          await Future<void>.delayed(const Duration(milliseconds: 350));
          // Update while in planning
          TitleUpdateBus.instance.emit(t2UpdatedAfter);
        },
        wait: const Duration(milliseconds: 100),
        verify: (bloc) {
          final planningItems = bloc.state.pagingStateFor(Bookmark.planning).items!;
          final movedItem = planningItems.first;
          expect(movedItem.userData!.rating, 8.0);
          expect(movedItem.userData!.note, 'updated after');
          expect(movedItem.userData!.bookmark, Bookmark.planning);
        },
      );
    });

    group('5. Update → transfer (updated data moves with item)', () {
      final t1 = _makeEntity(1, Bookmark.reading);
      final t2 = _makeEntity(2, Bookmark.reading);
      final t2UpdatedFirst = _makeEntity(2, Bookmark.reading, rating: 7, isFavorite: true);
      final t2Transferred = _makeEntity(2, Bookmark.planning, rating: 7, isFavorite: true);

      blocTest<FavoritesBloc, FavoritesState>(
        'item carries pre-transfer update when moved (if target is loaded, else just removed from source)',
        build: () => FavoritesBloc(repo),
        setUp: () => _stubFetch(repo, Bookmark.reading, 1, _makeSearchData([t1, t2])),
        act: (bloc) async {
          bloc.add(FavoritesFetchNextPage(Bookmark.reading));
          await Future<void>.delayed(const Duration(milliseconds: 350));
          // Update first
          TitleUpdateBus.instance.emit(t2UpdatedFirst);
          await Future<void>.delayed(const Duration(milliseconds: 350));
          // Then transfer
          TitleUpdateBus.instance.emit(t2Transferred);
        },
        wait: const Duration(milliseconds: 100),
        verify: (bloc) {
          final planningItems = bloc.state.pagingStateFor(Bookmark.planning).items;
          expect(planningItems, isNull); // Planning is not loaded yet

          // Reading should not contain t2 anymore
          final readingIds = bloc.state
              .pagingStateFor(Bookmark.reading)
              .items
              ?.map((e) => e.title.id);
          expect(readingIds, [1]);
        },
      );
    });

    group('6. Handling of new or non-loaded titles', () {
      final t1 = _makeEntity(1, Bookmark.reading);
      final newTitleInReading = _makeEntity(99, Bookmark.reading, rating: 5);
      final newTitleInPlanning = _makeEntity(100, Bookmark.planning);

      blocTest<FavoritesBloc, FavoritesState>(
        'should prepend new title to the bookmark when its page is already loaded',
        build: () => FavoritesBloc(repo),
        setUp: () => _stubFetch(repo, Bookmark.reading, 1, _makeSearchData([t1])),
        act: (bloc) async {
          bloc.add(FavoritesFetchNextPage(Bookmark.reading));
          await Future<void>.delayed(const Duration(milliseconds: 350));
          TitleUpdateBus.instance.emit(newTitleInReading);
        },
        wait: const Duration(milliseconds: 100),
        verify: (bloc) {
          final pagingState = bloc.state.pagingStateFor(Bookmark.reading);

          expect(
            pagingState.items?.map((e) => e.title.id),
            [99, 1], // New title is placed at the top
          );

          // Verify that it is prepended as a new individual page "0" at the beginning
          expect(pagingState.pages?.length, 2);
          expect(pagingState.pages?.first.first.title.id, 99);
          expect(pagingState.keys?.first, 0); // new key for top insertion
        },
      );

      blocTest<FavoritesBloc, FavoritesState>(
        'should ignore and not add new title when its bookmark page is empty (not loaded)',
        build: () => FavoritesBloc(repo),
        act: (bloc) async {
          TitleUpdateBus.instance.emit(newTitleInPlanning);
        },
        wait: const Duration(milliseconds: 100),
        verify: (bloc) {
          final planningItems = bloc.state.pagingStateFor(Bookmark.planning).items;
          expect(planningItems, isNull);
        },
      );
    });

    group('7. FetchNextPage deduplication while loading', () {
      final t1 = _makeEntity(1, Bookmark.reading);

      blocTest<FavoritesBloc, FavoritesState>(
        'second FetchNextPage while first is in-flight is ignored',
        build: () => FavoritesBloc(repo),
        setUp: () => _stubFetch(repo, Bookmark.reading, 1, _makeSearchData([t1])),
        act: (bloc) {
          bloc
            ..add(FavoritesFetchNextPage(Bookmark.reading))
            ..add(FavoritesFetchNextPage(Bookmark.reading));
        },
        wait: const Duration(milliseconds: 100),
        verify: (_) {
          // Repo searchTitles should be called exactly once (page=1)
          verify(
            () => repo.searchTitles(
              bookmark: Bookmark.reading,
              filter: any(named: 'filter'),
              page: 1,
            ),
          ).called(1);
        },
      );
    });

    group('8. FetchNextPage when no more pages', () {
      final t1 = _makeEntity(1, Bookmark.reading);

      blocTest<FavoritesBloc, FavoritesState>(
        'does not call repository when hasNextPage is false',
        build: () => FavoritesBloc(repo),
        setUp: () => _stubFetch(repo, Bookmark.reading, 1, _makeSearchData([t1])),
        act: (bloc) async {
          bloc.add(FavoritesFetchNextPage(Bookmark.reading));
          await Future<void>.delayed(const Duration(milliseconds: 350));
          // hasNextPage is now false — second event should be a no-op
          bloc.add(FavoritesFetchNextPage(Bookmark.reading));
        },
        wait: const Duration(milliseconds: 100),
        verify: (_) {
          verify(
            () => repo.searchTitles(
              bookmark: Bookmark.reading,
              filter: any(named: 'filter'),
              page: any(named: 'page'),
            ),
          ).called(1);
        },
      );
    });

    group('9. API failure handling', () {
      const failure = ConnectionTimeoutFailure();

      blocTest<FavoritesBloc, FavoritesState>(
        'sets error in paging state and clears isLoading',
        build: () => FavoritesBloc(repo),
        setUp: () {
          when(
            () => repo.searchTitles(
              bookmark: Bookmark.reading,
              filter: any(named: 'filter'),
              page: any(named: 'page'),
            ),
          ).thenAnswer((_) async => const Left(failure));
        },
        act: (bloc) => bloc.add(FavoritesFetchNextPage(Bookmark.reading)),
        wait: const Duration(milliseconds: 100),
        verify: (bloc) {
          final pagingState = bloc.state.pagingStateFor(Bookmark.reading);
          expect(pagingState.error, failure);
          expect(pagingState.isLoading, isFalse);
        },
      );
    });

    group('10. FilterApplied resets all paging states', () {
      final t1 = _makeEntity(1, Bookmark.reading);
      final t2 = _makeEntity(2, Bookmark.planning);
      const newFilter = TitleFilter(minRating: 8);

      blocTest<FavoritesBloc, FavoritesState>(
        'clears all pagingStates and applies new filter',
        build: () => FavoritesBloc(repo),
        setUp: () {
          _stubFetch(repo, Bookmark.reading, 1, _makeSearchData([t1]));
          _stubFetch(repo, Bookmark.planning, 1, _makeSearchData([t2]));
        },
        act: (bloc) async {
          bloc.add(FavoritesFetchNextPage(Bookmark.reading));
          await Future<void>.delayed(const Duration(milliseconds: 350));
          bloc.add(FavoritesFetchNextPage(Bookmark.planning));
          await Future<void>.delayed(const Duration(milliseconds: 350));
          bloc.add(FavoritesFilterApplied(newFilter));
        },
        wait: const Duration(milliseconds: 100),
        verify: (bloc) {
          expect(bloc.state.pagingStates, isEmpty);
          expect(bloc.state.filter, newFilter);
        },
      );
    });

    group('11. Transfer to a bookmark that was never loaded', () {
      final t1 = _makeEntity(1, Bookmark.reading);
      final t2 = _makeEntity(2, Bookmark.reading);
      final t2TransferredToDropped = _makeEntity(2, Bookmark.dropped);

      blocTest<FavoritesBloc, FavoritesState>(
        'should NOT create first page with the transferred item when moved to an unloaded bookmark',
        build: () => FavoritesBloc(repo),
        setUp: () => _stubFetch(repo, Bookmark.reading, 1, _makeSearchData([t1, t2])),
        act: (bloc) async {
          bloc.add(FavoritesFetchNextPage(Bookmark.reading));
          await Future<void>.delayed(const Duration(milliseconds: 350));
          TitleUpdateBus.instance.emit(t2TransferredToDropped);
        },
        wait: const Duration(milliseconds: 100),
        verify: (bloc) {
          final droppedState = bloc.state.pagingStateFor(Bookmark.dropped);

          expect(droppedState.items, isNull);
          expect(droppedState.pages, isNull);

          final readingIds = bloc.state
              .pagingStateFor(Bookmark.reading)
              .items
              ?.map((e) => e.title.id);
          expect(readingIds, [1]);

          // Dropped bookmark still has hasNextPage: true so further pages can load
          expect(
            droppedState.hasNextPage,
            isTrue,
          );
        },
      );
    });

    group('12. Transfer back to original bookmark', () {
      final t1 = _makeEntity(1, Bookmark.reading);
      final t2 = _makeEntity(2, Bookmark.reading);
      final t3 = _makeEntity(3, Bookmark.planning);
      final t2ToPlanning = _makeEntity(2, Bookmark.planning);
      final t2BackToReading = _makeEntity(2, Bookmark.reading, rating: 6);

      blocTest<FavoritesBloc, FavoritesState>(
        'item returns to reading after being moved out and back',
        build: () => FavoritesBloc(repo),
        setUp: () {
          _stubFetch(repo, Bookmark.reading, 1, _makeSearchData([t1, t2]));
          _stubFetch(repo, Bookmark.planning, 1, _makeSearchData([t3]));
        },
        act: (bloc) async {
          bloc.add(FavoritesFetchNextPage(Bookmark.reading));
          await Future<void>.delayed(const Duration(milliseconds: 350));
          bloc.add(FavoritesFetchNextPage(Bookmark.planning));
          await Future<void>.delayed(const Duration(milliseconds: 350));
          TitleUpdateBus.instance.emit(t2ToPlanning);
          await Future<void>.delayed(const Duration(milliseconds: 350));
          TitleUpdateBus.instance.emit(t2BackToReading);
        },
        wait: const Duration(milliseconds: 100),
        verify: (bloc) {
          final readingIds = bloc.state
              .pagingStateFor(Bookmark.reading)
              .items
              ?.map((e) => e.title.id);
          final planningIds = bloc.state
              .pagingStateFor(Bookmark.planning)
              .items
              ?.map((e) => e.title.id);

          expect(readingIds, containsAll([1, 2]));
          expect(planningIds, [3]);

          final t2InReading = bloc.state
              .pagingStateFor(Bookmark.reading)
              .items!
              .firstWhere((e) => e.title.id == 2);
          expect(t2InReading.userData!.rating, 6.0);
        },
      );
    });

    group('13. Transfer removes last item from a bookmark', () {
      final t1 = _makeEntity(1, Bookmark.reading);
      final t1Transferred = _makeEntity(1, Bookmark.completed);

      blocTest<FavoritesBloc, FavoritesState>(
        'reading becomes empty, completed remains unloaded',
        build: () => FavoritesBloc(repo),
        setUp: () => _stubFetch(repo, Bookmark.reading, 1, _makeSearchData([t1])),
        act: (bloc) async {
          bloc.add(FavoritesFetchNextPage(Bookmark.reading));
          await Future<void>.delayed(const Duration(milliseconds: 350));
          TitleUpdateBus.instance.emit(t1Transferred);
        },
        wait: const Duration(milliseconds: 100),
        verify: (bloc) {
          final readingItems = bloc.state.pagingStateFor(Bookmark.reading).items;
          expect(readingItems, isEmpty);

          final completedItems = bloc.state.pagingStateFor(Bookmark.completed).items;
          expect(completedItems, isNull);
        },
      );
    });

    group('14. Multiple sequential transfers of same item', () {
      final t1 = _makeEntity(1, Bookmark.reading);
      final t2 = _makeEntity(2, Bookmark.reading);
      final t2ToPlanning = _makeEntity(2, Bookmark.planning);
      final t2ToCompleted = _makeEntity(2, Bookmark.completed);
      final t2ToDropped = _makeEntity(2, Bookmark.dropped);

      blocTest<FavoritesBloc, FavoritesState>(
        'tracks item removal across successive bookmark changes when target bookmarks are unloaded',
        build: () => FavoritesBloc(repo),
        setUp: () => _stubFetch(repo, Bookmark.reading, 1, _makeSearchData([t1, t2])),
        act: (bloc) async {
          bloc.add(FavoritesFetchNextPage(Bookmark.reading));
          await Future<void>.delayed(const Duration(milliseconds: 350));
          TitleUpdateBus.instance.emit(t2ToPlanning);
          await Future<void>.delayed(const Duration(milliseconds: 350));
          TitleUpdateBus.instance.emit(t2ToCompleted);
          await Future<void>.delayed(const Duration(milliseconds: 350));
          TitleUpdateBus.instance.emit(t2ToDropped);
        },
        wait: const Duration(milliseconds: 100),
        verify: (bloc) {
          // Only 1 left in reading
          expect(
            bloc.state.pagingStateFor(Bookmark.reading).items?.map((e) => e.title.id),
            [1],
          );

          // Unloaded bookmarks should remain unloaded
          expect(
            bloc.state.pagingStateFor(Bookmark.planning).items,
            isNull,
          );
          expect(
            bloc.state.pagingStateFor(Bookmark.completed).items,
            isNull,
          );
          expect(
            bloc.state.pagingStateFor(Bookmark.dropped).items,
            isNull,
          );
        },
      );
    });

    group('15. Filter is forwarded to repository on next fetch', () {
      final t1 = _makeEntity(1, Bookmark.reading);
      const newFilter = TitleFilter(minRating: 7, maxChapters: 100);

      blocTest<FavoritesBloc, FavoritesState>(
        'searchTitles receives the applied filter',
        build: () => FavoritesBloc(repo),
        setUp: () {
          when(
            () => repo.searchTitles(
              bookmark: Bookmark.reading,
              filter: newFilter,
              page: 1,
            ),
          ).thenAnswer((_) async => Right(_makeSearchData([t1])));
        },
        act: (bloc) async {
          bloc.add(FavoritesFilterApplied(newFilter));
          await Future<void>.delayed(const Duration(milliseconds: 10));
          bloc.add(FavoritesFetchNextPage(Bookmark.reading));
        },
        wait: const Duration(milliseconds: 100),
        verify: (_) {
          verify(
            () => repo.searchTitles(
              bookmark: Bookmark.reading,
              filter: newFilter,
              page: 1,
            ),
          ).called(1);
        },
      );
    });

    group('16. Concurrent updates to two bookmarks', () {
      final t1 = _makeEntity(1, Bookmark.reading);
      final t2 = _makeEntity(2, Bookmark.planning);
      final t1Updated = _makeEntity(1, Bookmark.reading, rating: 5);
      final t2Updated = _makeEntity(2, Bookmark.planning, rating: 9);

      blocTest<FavoritesBloc, FavoritesState>(
        'each update lands at the top of its correct bookmark',
        build: () => FavoritesBloc(repo),
        setUp: () {
          _stubFetch(repo, Bookmark.reading, 1, _makeSearchData([t1]));
          _stubFetch(repo, Bookmark.planning, 1, _makeSearchData([t2]));
        },
        act: (bloc) async {
          bloc.add(FavoritesFetchNextPage(Bookmark.reading));
          await Future<void>.delayed(const Duration(milliseconds: 350));
          bloc.add(FavoritesFetchNextPage(Bookmark.planning));
          await Future<void>.delayed(const Duration(milliseconds: 350));
          TitleUpdateBus.instance.emit(t1Updated);
          await Future<void>.delayed(const Duration(milliseconds: 350));
          TitleUpdateBus.instance.emit(t2Updated);
        },
        wait: const Duration(milliseconds: 100),
        verify: (bloc) {
          expect(
            bloc.state.pagingStateFor(Bookmark.reading).items?.first.userData!.rating,
            5.0,
          );
          expect(
            bloc.state.pagingStateFor(Bookmark.planning).items?.first.userData!.rating,
            9.0,
          );
        },
      );
    });

    group('17. Pagination continues after filter reset', () {
      final t1 = _makeEntity(1, Bookmark.reading);
      final t2 = _makeEntity(2, Bookmark.reading);

      blocTest<FavoritesBloc, FavoritesState>(
        'after FilterApplied the next fetch starts from page 1 again',
        build: () => FavoritesBloc(repo),
        setUp: () {
          _stubFetch(repo, Bookmark.reading, 1, _makeSearchData([t1], hasNextPage: true));
          when(
            () => repo.searchTitles(
              bookmark: Bookmark.reading,
              filter: const TitleFilter(minRating: 6),
              page: 1,
            ),
          ).thenAnswer((_) async => Right(_makeSearchData([t2])));
        },
        act: (bloc) async {
          bloc.add(FavoritesFetchNextPage(Bookmark.reading));
          await Future<void>.delayed(const Duration(milliseconds: 350));
          bloc.add(FavoritesFilterApplied(const TitleFilter(minRating: 6)));
          await Future<void>.delayed(const Duration(milliseconds: 10));
          bloc.add(FavoritesFetchNextPage(Bookmark.reading));
        },
        wait: const Duration(milliseconds: 100),
        verify: (bloc) {
          // Only t2 should be visible (fresh load with new filter from page 1)
          expect(
            bloc.state.pagingStateFor(Bookmark.reading).items?.map((e) => e.title.id),
            [2],
          );
        },
      );
    });
  });
}
