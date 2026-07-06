import 'dart:async';

import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shinga/core/core.dart';
import 'package:shinga/domain/domain.dart';
import 'package:shinga/features/users/users.dart';
import 'package:stream_transform/stream_transform.dart';

part 'user_profile_event.dart';
part 'user_profile_state.dart';

/// Handles profile data loading and refreshes statistics after title changes.
class UserProfileBloc extends Bloc<UserProfileEvent, UserProfileState> {
  /// Creates a [UserProfileBloc] instance.
  UserProfileBloc({required UserRepository userRepository}) : this._(userRepository);

  UserProfileBloc._(this._userRepository) : super(const UserProfileInitial()) {
    on<UserProfileStarted>(_onStarted);
    on<UserProfileRefreshRequested>(_onRefreshRequested);
    on<_UserProfileTitleUpdated>(
      _onTitleUpdated,
      transformer: _profileRefreshTransformer(),
    );

    _titleUpdateSub = TitleUpdateBus.instance.updates.listen(
      (entity) => add(_UserProfileTitleUpdated(entity)),
    );
  }

  final UserRepository _userRepository;
  late final StreamSubscription<TitleWithUserDataEntity> _titleUpdateSub;

  Future<void> _onStarted(
    UserProfileStarted event,
    Emitter<UserProfileState> emit,
  ) async {
    emit(UserProfileLoading(initialUser: event.initialUser));
    await _loadProfile(emit, initialUser: event.initialUser);
  }

  Future<void> _onRefreshRequested(
    UserProfileRefreshRequested event,
    Emitter<UserProfileState> emit,
  ) async {
    final currentState = state;
    switch (currentState) {
      case UserProfileLoaded(:final user, :final statistics):
        emit(
          UserProfileLoaded(
            user: user,
            statistics: statistics,
            isRefreshing: true,
          ),
        );
        await _loadProfile(emit, initialUser: user);
      case UserProfileFailure(:final initialUser):
        emit(UserProfileLoading(initialUser: initialUser));
        await _loadProfile(emit, initialUser: initialUser);
      case UserProfileLoading() || UserProfileInitial():
        break;
    }
  }

  Future<void> _onTitleUpdated(
    _UserProfileTitleUpdated event,
    Emitter<UserProfileState> emit,
  ) async {
    final currentState = state;
    if (currentState is! UserProfileLoaded) return;

    emit(currentState.copyWith(isRefreshing: true));
    final result = await _userRepository.getStatistics();
    result.fold(
      (failure) => emit(
        currentState.copyWith(
          isRefreshing: false,
          refreshFailure: failure,
        ),
      ),
      (statistics) => emit(
        UserProfileLoaded(
          user: currentState.user,
          statistics: statistics,
        ),
      ),
    );
  }

  Future<void> _loadProfile(
    Emitter<UserProfileState> emit, {
    required UserEntity? initialUser,
  }) async {
    final userFuture = _userRepository.getCurrentUser();
    final statisticsFuture = _userRepository.getStatistics();

    final userResult = await userFuture;
    final statisticsResult = await statisticsFuture;

    AppFailure? failure;
    UserEntity? user;
    UserStatisticsEntity? statistics;

    userResult.fold(
      (value) => failure = value,
      (value) => user = value,
    );
    if (failure != null) {
      emit(UserProfileFailure(failure: failure!, initialUser: initialUser));
      return;
    }

    statisticsResult.fold(
      (value) => failure = value,
      (value) => statistics = value,
    );
    if (failure != null) {
      emit(UserProfileFailure(failure: failure!, initialUser: user ?? initialUser));
      return;
    }

    emit(UserProfileLoaded(user: user!, statistics: statistics!));
  }

  @override
  Future<void> close() async {
    await _titleUpdateSub.cancel();
    return super.close();
  }
}

EventTransformer<E> _profileRefreshTransformer<E>({
  Duration duration = const Duration(milliseconds: 600),
}) {
  return (events, mapper) {
    return restartable<E>().call(events.debounce(duration), mapper);
  };
}
