import 'package:flutter/material.dart';
import 'package:timeago/timeago.dart' as timeago;

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

  runApp(TranslationProvider(child: const MainApp()));
}
