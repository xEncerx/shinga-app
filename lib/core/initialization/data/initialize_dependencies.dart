import 'dart:async';

import 'package:dio_cache_interceptor/dio_cache_interceptor.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http_cache_hive_store/http_cache_hive_store.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shinga/core/core.dart';
import 'package:shinga/data/data.dart';
import 'package:shinga/data/hive/hive_registrar.g.dart';
import 'package:shinga/features/features.dart';
import 'package:storage/storage.dart';
import 'package:talker/talker.dart';
import 'package:talker_bloc_logger/talker_bloc_logger.dart';
import 'package:talker_dio_logger/talker_dio_logger.dart';
import 'package:webview_guardian/webview_guardian.dart';
import 'package:window_manager/window_manager.dart';

const _kProjectDBFolder = 'shinga/storage/db';

/// Initializes the application's dependencies.
Future<Dependencies> $initializeDependencies({
  void Function(int progress, String message)? onProgress,
}) async {
  final deps = $MutableDependencies();
  final steps = _initializationSteps;
  var currentStep = 0;

  for (final step in steps.entries) {
    currentStep++;
    final percent = (currentStep * 100 ~/ steps.length).clamp(0, 100);
    onProgress?.call(percent, step.key);
    await step.value(deps);
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
  // 'Setup proxy': (_) async {
  //   // Setup proxy only for windows.
  //   if (defaultTargetPlatform != TargetPlatform.windows) return;
  //   final proxySettings = await proxySetting();
  //   HttpOverrides.global = ProxyHttpOverrides(proxySettings);
  // },
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

  'Initialize storages': (deps) async {
    final documentsDir = await getApplicationDocumentsDirectory();
    final secureStorage = SecureStorage();

    Hive.registerAdapters();

    final userSession = HiveCollectionStorage<SessionDTO>(boxName: 'user_session');
    final searchHistory = HiveCollectionStorage<TitleSearchHistoryItemDTO>(
      boxName: 'title_search_history',
    );
    final appSettings = HiveCollectionStorage<AppSettingsDTO>(boxName: 'app_settings');
    final httpCache = HiveCacheStore(
      '${documentsDir.path}/shinga/storage/cache',
      hiveBoxName: 'http_cache',
    );

    await secureStorage.init();
    await userSession.init(_kProjectDBFolder);
    await searchHistory.init(_kProjectDBFolder);
    await appSettings.init(_kProjectDBFolder);

    deps.context['secure_storage'] = secureStorage;
    deps.context['user_session_storage'] = userSession;
    deps.context['search_history_storage'] = searchHistory;
    deps.context['http_cache'] = httpCache;

    deps
      ..appSettingsRepository = AppSettingsRepositoryImpl(appSettings)
      ..sessionRepository = SessionRepositoryImpl(userSession)
      ..searchHistoryRepository = TitleSearchHistoryRepositoryImpl(searchHistory);
  },

  'Initialize localization': (deps) async {
    await LocalizationService(deps.appSettingsRepository).initialize();
  },

  'Initialize network': (deps) {
    final secureStorage = deps.context['secure_storage']! as SecureStorage;
    final httpCache = deps.context['http_cache']! as HiveCacheStore;
    final dioObserver = deps.context['dio_observer']! as TalkerDioLogger;

    final tokenRepository = TokenRepositoryImpl(secureStorage);
    deps.context['token_repository'] = tokenRepository;

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
    final adBlocker = await AdBlockerService(
      settingsRepository: deps.appSettingsRepository,
      observer: observer,
    ).initialize();

    deps
      ..webViewObserver = observer
      ..adBlocker = adBlocker;
  },

  'Initialize router': (deps) {
    deps.appRouter = AppRouter();
  },
};
