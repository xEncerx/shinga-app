import 'package:flutter/widgets.dart';
import 'package:shinga/core/core.dart';
import 'package:shinga/domain/domain.dart';
import 'package:shinga/features/features.dart';
import 'package:talker/talker.dart';
import 'package:webview_guardian/webview_guardian.dart';

/// Dependencies of the application.
abstract interface class Dependencies {
  /// The state from the closest instance of this class.
  factory Dependencies.of(BuildContext context) => InheritedDependencies.of(context);

  /// Logger
  abstract final Talker logger;

  /// App settings repository
  abstract final AppSettingsRepository appSettingsRepository;

  /// Authentication repository
  abstract final AuthRepository authRepository;

  /// User repository
  abstract final UserRepository userRepository;

  /// User titles repository
  abstract final UserTitlesRepository userTitlesRepository;

  /// Title repository
  abstract final TitleRepository titleRepository;

  /// Title filter repository
  abstract final TitleFilterRepository titleFilterRepository;

  /// Session repository
  abstract final SessionRepository sessionRepository;

  /// Title search history repository
  abstract final TitleSearchHistoryRepository searchHistoryRepository;

  /// AdBlocker service
  abstract final AdblockService adBlocker;

  /// WebView observer
  abstract final StreamWebViewObserver webViewObserver;

  /// App router
  abstract final AppRouter appRouter;
}

/// Mutable dependencies used during initialization. After initialization, dependencies are frozen and become immutable.
final class $MutableDependencies implements Dependencies {
  /// Creates a [$MutableDependencies] instance.
  $MutableDependencies() : context = {};

  /// Initialization context
  final Map<Object?, Object?> context;

  @override
  late Talker logger;
  @override
  late AppSettingsRepository appSettingsRepository;
  @override
  late AuthRepository authRepository;
  @override
  late UserRepository userRepository;
  @override
  late UserTitlesRepository userTitlesRepository;
  @override
  late TitleRepository titleRepository;
  @override
  late TitleFilterRepository titleFilterRepository;
  @override
  late SessionRepository sessionRepository;
  @override
  late TitleSearchHistoryRepository searchHistoryRepository;
  @override
  late AdblockService adBlocker;
  @override
  late StreamWebViewObserver webViewObserver;
  @override
  late AppRouter appRouter;

  /// Freezes the dependencies, making them immutable.
  Dependencies freeze() => _$ImmutableDependencies(
    logger: logger,
    appSettingsRepository: appSettingsRepository,
    authRepository: authRepository,
    userRepository: userRepository,
    userTitlesRepository: userTitlesRepository,
    titleRepository: titleRepository,
    titleFilterRepository: titleFilterRepository,
    sessionRepository: sessionRepository,
    searchHistoryRepository: searchHistoryRepository,
    adBlocker: adBlocker,
    webViewObserver: webViewObserver,
    appRouter: appRouter,
  );
}

final class _$ImmutableDependencies implements Dependencies {
  const _$ImmutableDependencies({
    required this.logger,
    required this.appSettingsRepository,
    required this.authRepository,
    required this.userRepository,
    required this.userTitlesRepository,
    required this.titleRepository,
    required this.titleFilterRepository,
    required this.sessionRepository,
    required this.searchHistoryRepository,
    required this.adBlocker,
    required this.webViewObserver,
    required this.appRouter,
  });

  @override
  final Talker logger;
  @override
  final AppSettingsRepository appSettingsRepository;
  @override
  final AuthRepository authRepository;
  @override
  final UserRepository userRepository;
  @override
  final UserTitlesRepository userTitlesRepository;
  @override
  final TitleRepository titleRepository;
  @override
  final TitleFilterRepository titleFilterRepository;
  @override
  final SessionRepository sessionRepository;
  @override
  final TitleSearchHistoryRepository searchHistoryRepository;
  @override
  final AdblockService adBlocker;
  @override
  final StreamWebViewObserver webViewObserver;
  @override
  final AppRouter appRouter;
}
