import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fpdart/fpdart.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:shinga/core/core.dart';
import 'package:shinga/domain/domain.dart';
import 'package:shinga/features/features.dart';

part 'title_detail_cubit.freezed.dart';
part 'title_detail_state.dart';

/// Cubit for managing the state of the title detail screen, including user interactions.
class TitleDetailCubit extends Cubit<TitleDetailState> {
  /// Creates a [TitleDetailCubit] instance.
  TitleDetailCubit({
    required TitleWithUserDataEntity initialData,
    required this._userTitlesRepository,
  }) : super(TitleDetailState(data: initialData)) {
    _titleUpdateSub = TitleUpdateBus.instance.updates.listen(_onTitleUpdated);
  }

  /// Repository for managing user-specific title data.
  final UserTitlesRepository _userTitlesRepository;

  late final StreamSubscription<TitleWithUserDataEntity> _titleUpdateSub;

  /// Method to add or update the user's bookmark for the current title.
  Future<void> addToBookmark(Bookmark bookmark) async => _runFieldAction(
    field: TitleDetailField.bookmark,
    action: _userTitlesRepository.addUserTitle(
      titleId: state.data.title.id,
      bookmark: bookmark,
    ),
    onSuccess: (_) {
      final userData = state.data.userData ?? UserTitleDataEntity(bookmark: bookmark);
      final updated = state.data.copyWith(userData: userData.copyWith(bookmark: bookmark));
      TitleUpdateBus.instance.emit(updated);
    },
  );

  /// Changes the user's bookmark for the current title.
  Future<void> changeBookmark(Bookmark newBookmark) async {
    if (state.data.userData == null) {
      emit(state.copyWith(failure: const UserTitleNotFoundFailure()));
      return;
    }

    await _runFieldAction(
      field: TitleDetailField.bookmark,
      action: _userTitlesRepository.updateUserTitle(
        titleId: state.data.title.id,
        updateParams: UpdateUserTitleParams(bookmark: newBookmark),
      ),
      onSuccess: (_) {
        final userData = state.data.userData!;
        final updated = state.data.copyWith(userData: userData.copyWith(bookmark: newBookmark));
        TitleUpdateBus.instance.emit(updated);
      },
    );
  }

  /// Changes the user's rating for the current title.
  Future<void> changeRating(double newRating) async {
    if (state.data.userData == null) {
      emit(state.copyWith(failure: const UserTitleNotFoundFailure()));
      return;
    }
    if (state.data.userData!.rating == newRating) {
      // If the new rating is the same as the current one, we can skip the update.
      return;
    }

    await _runFieldAction(
      field: TitleDetailField.rating,
      action: _userTitlesRepository.updateUserTitle(
        titleId: state.data.title.id,
        updateParams: UpdateUserTitleParams(rating: newRating.roundToDouble()),
      ),
      onSuccess: (_) {
        final userData = state.data.userData!;
        final updated = state.data.copyWith(userData: userData.copyWith(rating: newRating));
        TitleUpdateBus.instance.emit(updated);
      },
    );
  }

  /// Changes the user's current URL for the current title.
  Future<void> changeCurrentUrl(String newCurrentUrl) async {
    if (state.data.userData == null) {
      emit(state.copyWith(failure: const UserTitleNotFoundFailure()));
      return;
    }

    await _runFieldAction(
      field: TitleDetailField.currentUrl,
      action: _userTitlesRepository.updateUserTitle(
        titleId: state.data.title.id,
        updateParams: UpdateUserTitleParams(currentUrl: newCurrentUrl),
      ),
      onSuccess: (_) {
        final userData = state.data.userData!;
        final updated = state.data.copyWith(userData: userData.copyWith(currentUrl: newCurrentUrl));
        TitleUpdateBus.instance.emit(updated);
      },
    );
  }

  /// Changes the user's favorite status for the current title.
  Future<void> changeIsFavorite(bool newIsFavorite) async {
    if (state.data.userData == null) {
      emit(state.copyWith(failure: const UserTitleNotFoundFailure()));
      return;
    }

    await _runFieldAction(
      field: null,
      action: _userTitlesRepository.updateUserTitle(
        titleId: state.data.title.id,
        updateParams: UpdateUserTitleParams(isFavorite: newIsFavorite),
      ),
      onSuccess: (_) {
        final userData = state.data.userData!;
        final updated = state.data.copyWith(userData: userData.copyWith(isFavorite: newIsFavorite));
        TitleUpdateBus.instance.emit(updated);
      },
    );
  }

  /// Changes the user's note for the current title.
  Future<void> changeNote(String newNote) async {
    if (state.data.userData == null) {
      emit(state.copyWith(failure: const UserTitleNotFoundFailure()));
      return;
    }

    await _runFieldAction(
      field: TitleDetailField.note,
      action: _userTitlesRepository.updateUserTitle(
        titleId: state.data.title.id,
        updateParams: UpdateUserTitleParams(note: newNote),
      ),
      onSuccess: (_) {
        final userData = state.data.userData!;
        final updated = state.data.copyWith(userData: userData.copyWith(note: newNote));
        TitleUpdateBus.instance.emit(updated);
      },
    );
  }

  Future<void> _runFieldAction<T>({
    required TitleDetailField? field,
    required Future<Either<AppFailure, T>> action,
    required void Function(T result) onSuccess,
  }) async {
    // Emit loading state for the specific field
    emit(
      state.copyWith(
        loadingFields: {...state.loadingFields, ?field},
        failure: null,
      ),
    );

    final result = await action;
    result.fold(
      (failure) {
        // Clear loading state and set failure for the field
        emit(
          state.copyWith(
            loadingFields: {...state.loadingFields}..remove(field),
            failure: failure,
          ),
        );
      },
      (value) {
        // Clear loading state for the field
        emit(
          state.copyWith(
            loadingFields: {...state.loadingFields}..remove(field),
          ),
        );

        onSuccess(value);
      },
    );
  }

  void _onTitleUpdated(TitleWithUserDataEntity updated) {
    emit(state.copyWith(data: updated));
  }

  @override
  Future<void> close() async {
    await _titleUpdateSub.cancel();
    return super.close();
  }
}
