part of 'app_settings_cubit.dart';

/// The state for application settings.
class AppSettingsState extends Equatable {
  /// Creates an [AppSettingsState] instance.
  const AppSettingsState({
    this.settings = AppSettings.defaults,
    this.isLoading = false,
    this.failure,
  });

  /// The current application settings.
  final AppSettings settings;

  /// Whether a settings operation is in progress.
  final bool isLoading;

  /// The failure that occurred during an operation, if any.
  final AppFailure? failure;

  /// Creates a copy of this state with the given fields replaced.
  AppSettingsState copyWith({
    AppSettings? settings,
    bool? isLoading,
    AppFailure? failure,
  }) {
    return AppSettingsState(
      settings: settings ?? this.settings,
      isLoading: isLoading ?? this.isLoading,
      failure: failure ?? this.failure,
    );
  }

  @override
  List<Object?> get props => [settings, isLoading, failure];
}
