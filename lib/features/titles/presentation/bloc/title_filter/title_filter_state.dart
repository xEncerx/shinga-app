part of 'title_filter_cubit.dart';

/// Base class for all [TitleFilterCubit] states.
sealed class TitleFilterState extends Equatable {
  @override
  List<Object> get props => [];
}

/// The initial state before any data has been requested.
final class TitleFilterInitial extends TitleFilterState {}

/// Data is being fetched from the network.
final class TitleFilterLoading extends TitleFilterState {}

/// Form data is loaded and ready. Holds both the source lists and the draft filter.
final class TitleFilterLoaded extends TitleFilterState {
  /// Creates a [TitleFilterLoaded] instance.
  TitleFilterLoaded({
    required this.allGenres,
    required this.allCategories,
    required this.types,
    required this.statuses,
    required this.draft,
  });

  /// All available genres fetched from the API.
  final List<TitleGenre> allGenres;

  /// All available categories fetched from the API.
  final List<TitleCategory> allCategories;

  /// All available publication types.
  final List<TitleType> types;

  /// All available publication statuses.
  final List<TitleStatus> statuses;

  /// The current uncommitted filter being edited by the user.
  final TitleFilter draft;

  /// Returns true if the given genre form is selected in the [draft].
  bool isGenreSelected(TitleGenre form) => draft.genres?.any((g) => g.name == form.name) ?? false;

  /// Returns true if the given category form is selected in the [draft].
  bool isCategorySelected(TitleCategory form) =>
      draft.categories?.any((c) => c.name == form.name) ?? false;

  /// Creates a copy of this state with the given fields replaced.
  TitleFilterLoaded copyWith({
    List<TitleGenre>? allGenres,
    List<TitleCategory>? allCategories,
    List<TitleType>? types,
    List<TitleStatus>? statuses,
    TitleFilter? draft,
  }) => TitleFilterLoaded(
    allGenres: allGenres ?? this.allGenres,
    allCategories: allCategories ?? this.allCategories,
    types: types ?? this.types,
    statuses: statuses ?? this.statuses,
    draft: draft ?? this.draft,
  );

  @override
  List<Object> get props => [
    allGenres,
    allCategories,
    types,
    statuses,
    draft,
  ];
}

/// A network or repository error occurred while loading form data.
final class TitleFilterFailure extends TitleFilterState {
  /// Creates a [TitleFilterFailure] instance.
  TitleFilterFailure({required this.failure});

  /// The failure that caused this state.
  final AppFailure failure;

  @override
  List<Object> get props => [failure];
}
