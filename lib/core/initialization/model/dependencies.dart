import 'dart:async';

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

  /// Releases long-lived services and persistence resources.
  Future<void> dispose();
}

/// Mutable dependencies used during initialization. After initialization, dependencies are frozen and become immutable.
final class $MutableDependencies implements Dependencies {
  /// Creates a [$MutableDependencies] instance.
  $MutableDependencies() : context = {}, _disposer = _DependencyDisposer();

  /// Initialization context
  final Map<Object?, Object?> context;

  final _DependencyDisposer _disposer;

  /// Registers a resource cleanup callback in initialization order.
  void addDisposer(FutureOr<void> Function() dispose) => _disposer.add(dispose);

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

  @override
  Future<void> dispose() => _disposer.dispose();

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
    disposer: _disposer,
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
    required this._disposer,
  });

  final _DependencyDisposer _disposer;

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

  @override
  Future<void> dispose() => _disposer.dispose();
}

final class _DependencyDisposer {
  final List<FutureOr<void> Function()> _callbacks = [];
  bool _isDisposed = false;

  void add(FutureOr<void> Function() callback) {
    if (_isDisposed) throw StateError('Dependencies have already been disposed.');
    _callbacks.add(callback);
  }

  Future<void> dispose() async {
    if (_isDisposed) return;
    _isDisposed = true;

    Object? firstError;
    StackTrace? firstStackTrace;
    for (final callback in _callbacks.reversed) {
      try {
        await callback();
      } on Object catch (error, stackTrace) {
        firstError ??= error;
        firstStackTrace ??= stackTrace;
      }
    }
    _callbacks.clear();

    if (firstError != null) {
      Error.throwWithStackTrace(firstError, firstStackTrace!);
    }
  }
}
