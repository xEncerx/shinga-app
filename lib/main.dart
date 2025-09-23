import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:window_manager/window_manager.dart';

import 'core/core.dart';
import 'data/data.dart';
import 'domain/domain.dart';
import 'i18n/strings.g.dart';
import 'utils/utils.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await setupDependencies();

  // Preload SVGs
  await preloadSVGs([
    'assets/svgs/yandex_logo.svg',
    'assets/svgs/google_logo.svg',
  ]);

  // Initialize the cache service
  CacheService.addCacheFolder(await CacheService.coverCacheDir);

  // Load timeago locales
  timeago.setLocaleMessages('ru', timeago.RuMessages());
  timeago.setLocaleMessages('en', timeago.EnMessages());

  // Set the initial locale for translations
  LocaleSettings.setLocale(getIt<AppSettings>().language);

  if (AppTheme.isDesktop) {
    await windowManager.ensureInitialized();

    const windowOptions = WindowOptions(
      skipTaskbar: false,
      size: Size(452, 777),
    );

    windowManager.waitUntilReadyToShow(windowOptions, () async {
      await windowManager.show();
      await windowManager.focus();
      await windowManager.setMaximizable(false);
      // Activate always on top in debug mode for easier testing
      if (kDebugMode) {
        await windowManager.setAlwaysOnTop(true);
      }
    });
  }

  runApp(
    TranslationProvider(
      child: const MainApp(),
    ),
  );
}
