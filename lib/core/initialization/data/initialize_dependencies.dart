import 'dart:async';
import 'dart:io';

import 'package:dio_cache_interceptor/dio_cache_interceptor.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http_cache_drift_store/http_cache_drift_store.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shinga/core/core.dart';
import 'package:shinga/data/data.dart';
import 'package:shinga/features/features.dart';
import 'package:system_proxy_reader/system_proxy_reader.dart';
import 'package:talker/talker.dart';
import 'package:talker_bloc_logger/talker_bloc_logger.dart';
import 'package:talker_dio_logger/talker_dio_logger.dart';
import 'package:webview_guardian/webview_guardian.dart';
import 'package:window_manager/window_manager.dart';

/// Initializes the application's dependencies.
Future<Dependencies> $initializeDependencies({
  void Function(int progress, String message)? onProgress,
}) async {
  final deps = $MutableDependencies();
  final steps = _initializationSteps;
  var currentStep = 0;

  try {
    for (final step in steps.entries) {
      currentStep++;
      final percent = (currentStep * 100 ~/ steps.length).clamp(0, 100);
      onProgress?.call(percent, step.key);
      await step.value(deps);
    }
  } on Object catch (error, stackTrace) {
    try {
      await deps.dispose();
    } on Object {
      // Preserve the initialization failure; cleanup errors are secondary.
    }
    Error.throwWithStackTrace(error, stackTrace);
  }

  return deps.freeze();
}

final Map<String, FutureOr<void> Function($MutableDependencies deps)> _initializationSteps = {
  'Platform initialization': (_) async {
    if (defaultTargetPlatform == TargetPlatform.windows ||
        defaultTargetPlatform == TargetPlatform.linux ||
        defaultTargetPlatform == TargetPlatform.macOS) {
      await windowManager.ensureInitialized();
      await windowManager.waitUntilReadyToShow(
        const WindowOptions(
          size: Size(450, 700),
          skipTaskbar: false,
          alwaysOnTop: kDebugMode,
        ),
      );
    }
  },
  'Initialize logger': (deps) {
    final talker = Talker();
    Bloc.observer = TalkerBlocObserver(
      talker: talker,
      settings: const TalkerBlocLoggerSettings(
        printEventFullData: false,
        printStateFullData: false,
      ),
    );
    deps.context['dio_observer'] = TalkerDioLogger(
      talker: talker,
      settings: const TalkerDioLoggerSettings(
        printResponseData: false,
        printResponseTime: true,
      ),
    );
    deps.logger = talker;
  },

  'Setup system proxy': (deps) async {
    if (!Platform.isWindows) return;

    try {
      final proxySettings = const WindowsProxyReader().read();
      if (proxySettings.hasAutomaticProxy) {
        deps.logger.warning('[Proxy] PAC/WPAD configuration is not supported yet');
      }
      if (!proxySettings.hasManualProxy) return;

      HttpOverrides.global = ProxyHttpOverrides(proxySettings);
      deps.logger.info('[Proxy] System proxy enabled: ${proxySettings.proxy}');
    } on Object catch (error) {
      deps.logger.error('[Proxy] Failed to read system proxy settings', error);
    }
  },

  'Initialize storages': (deps) async {
    const secureStorage = FlutterSecureStorage(
      iOptions: IOSOptions(
        accessibility: KeychainAccessibility.first_unlock,
      ),
    );
    final database = AppDatabase();
    deps.addDisposer(database.close);

    try {
      await database.customSelect('SELECT 1').getSingle();
    } on Object catch (error, stackTrace) {
      Error.throwWithStackTrace(
        StorageInitializationException('Failed to initialize app database: $error'),
        stackTrace,
      );
    }

    final cacheDirectory = await getApplicationCacheDirectory();
    final httpCache = DriftCacheStore(
      databasePath: Directory.fromUri(
        cacheDirectory.uri.resolve('shinga/http_cache/'),
      ).path,
      databaseName: 'http_cache',
    );
    deps.addDisposer(httpCache.close);

    deps.context['secure_storage'] = secureStorage;
    deps.context['http_cache'] = httpCache;

    deps
      ..appSettingsRepository = AppSettingsRepositoryImpl(database.appSettingsDao)
      ..sessionRepository = SessionRepositoryImpl(database.sessionDao)
      ..searchHistoryRepository = TitleSearchHistoryRepositoryImpl(
        database.titleSearchHistoryDao,
      );
  },

  'Initialize localization': (deps) async {
    final localizationService = LocalizationService(deps.appSettingsRepository);
    await localizationService.initialize();
    deps.addDisposer(localizationService.dispose);
  },

  'Initialize network': (deps) async {
    final secureStorage = deps.context['secure_storage']! as FlutterSecureStorage;
    final httpCache = deps.context['http_cache']! as DriftCacheStore;
    final dioObserver = deps.context['dio_observer']! as TalkerDioLogger;

    final tokenRepository = TokenRepositoryImpl(secureStorage);
    deps.context['token_repository'] = tokenRepository;

    if (await deps.sessionRepository.getSession() == null) {
      await tokenRepository.deleteToken();
    }

    final apiClient = DioClient(
      baseUrl: Settings.apiBaseUrl,
      interceptors: [
        AuthInterceptor(tokenRepository, deps.sessionRepository),
        DioCacheInterceptor(
          options: CacheOptions(
            store: httpCache,
            hitCacheOnNetworkFailure: true,
            maxStale: const Duration(days: 7),
          ),
        ),
        dioObserver,
      ],
    ).createClient();

    final userApiClient = UserApiClient(apiClient);

    deps
      ..authRepository = AuthRepositoryImpl(
        authApiClient: AuthApiClient(apiClient),
        userRepository: UserRepositoryImpl(userApiClient),
        tokenRepository: tokenRepository,
        sessionRepository: deps.sessionRepository,
      )
      ..userRepository = UserRepositoryImpl(userApiClient)
      ..userTitlesRepository = UserTitlesRepositoryImpl(UserTitlesApiClient(apiClient))
      ..titleRepository = TitleRepositoryImpl(TitleApiClient(apiClient))
      ..titleFilterRepository = TitleFilterRepositoryImpl(TitleFormApiClient(apiClient));
  },

  'Initialize ad blocker': (deps) async {
    final observer = StreamWebViewObserver(delegates: [AdBlockerObserver(deps.logger)]);
    final adBlockerService = AdBlockerService(
      settingsRepository: deps.appSettingsRepository,
      observer: observer,
    );
    final adBlocker = await adBlockerService.initialize();
    deps
      ..addDisposer(adBlockerService.dispose)
      ..addDisposer(observer.dispose)
      ..webViewObserver = observer
      ..adBlocker = adBlocker;
  },

  'Initialize router': (deps) {
    deps.appRouter = AppRouter();
  },
};
