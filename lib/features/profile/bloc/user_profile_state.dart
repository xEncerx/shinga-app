part of 'user_profile_bloc.dart';

/// Base state for profile data loading.
sealed class UserProfileState extends Equatable {
  /// Creates a [UserProfileState] instance.
  const UserProfileState();

  @override
  List<Object?> get props => [];
}

/// Profile data has not been requested yet.
final class UserProfileInitial extends UserProfileState {
  /// Creates a [UserProfileInitial] state.
  const UserProfileInitial();
}

/// Profile data is being loaded.
final class UserProfileLoading extends UserProfileState {
  /// Creates a [UserProfileLoading] state.
  const UserProfileLoading({this.initialUser});

  /// User from the current session, if available.
  final UserEntity? initialUser;

  @override
  List<Object?> get props => [initialUser];
}

/// Profile data has been loaded.
final class UserProfileLoaded extends UserProfileState {
  /// Creates a [UserProfileLoaded] state.
  const UserProfileLoaded({
    required this.user,
    required this.statistics,
    this.isRefreshing = false,
    this.refreshFailure,
  });

  /// Loaded current user.
  final UserEntity user;

  /// Loaded current user statistics.
  final UserStatisticsEntity statistics;

  /// Whether a background refresh is in progress.
  final bool isRefreshing;

  /// Failure returned by a background refresh.
  final AppFailure? refreshFailure;

  /// Creates a copy of this state with updated fields.
  UserProfileLoaded copyWith({
    UserEntity? user,
    UserStatisticsEntity? statistics,
    bool? isRefreshing,
    AppFailure? refreshFailure,
  }) {
    return UserProfileLoaded(
      user: user ?? this.user,
      statistics: statistics ?? this.statistics,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      refreshFailure: refreshFailure,
    );
  }

  @override
  List<Object?> get props => [user, statistics, isRefreshing, refreshFailure];
}

/// Profile data loading failed.
final class UserProfileFailure extends UserProfileState {
  /// Creates a [UserProfileFailure] state.
  const UserProfileFailure({required this.failure, this.initialUser});

  /// Failure returned by the repository.
  final AppFailure failure;

  /// User from the current session, if available.
  final UserEntity? initialUser;

  @override
  List<Object?> get props => [failure, initialUser];
}
