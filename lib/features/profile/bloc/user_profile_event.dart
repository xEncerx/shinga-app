part of 'user_profile_bloc.dart';

/// Base event for profile data loading.
sealed class UserProfileEvent extends Equatable {
  /// Creates a [UserProfileEvent] instance.
  const UserProfileEvent();

  @override
  List<Object?> get props => [];
}

/// Requests the initial profile load.
final class UserProfileStarted extends UserProfileEvent {
  /// Creates a [UserProfileStarted] event.
  const UserProfileStarted({this.initialUser});

  /// User from the active session, used while fresh data is loading.
  final UserEntity? initialUser;

  @override
  List<Object?> get props => [initialUser];
}

/// Requests a manual profile refresh.
final class UserProfileRefreshRequested extends UserProfileEvent {
  /// Creates a [UserProfileRefreshRequested] event.
  const UserProfileRefreshRequested();
}

final class _UserProfileTitleUpdated extends UserProfileEvent {
  const _UserProfileTitleUpdated(this.entity);

  final TitleWithUserDataEntity entity;

  @override
  List<Object?> get props => [entity];
}
