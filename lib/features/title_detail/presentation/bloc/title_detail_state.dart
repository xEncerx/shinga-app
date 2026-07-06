part of 'title_detail_cubit.dart';

/// Fields of the title detail that can be in a loading state.
enum TitleDetailField {
  /// The bookmark field.
  bookmark,

  /// The user note field.
  note,

  /// The current URL field.
  currentUrl,

  /// The user's rating field.
  rating,
}

/// Represents the state of the title detail.
@freezed
abstract class TitleDetailState with _$TitleDetailState {
  /// Creates a [TitleDetailState] instance.
  const factory TitleDetailState({
    required TitleWithUserDataEntity data,
    @Default({}) Set<TitleDetailField> loadingFields,
    AppFailure? failure,
  }) = _TitleDetailState;

  const TitleDetailState._();

  /// Checks if a specific field is loading.
  bool isFieldLoading(TitleDetailField field) => loadingFields.contains(field);

  /// Checks if the title has user data.
  bool get hasUserData => data.userData != null;
}
