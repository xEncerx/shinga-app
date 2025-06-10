import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:window_manager/window_manager.dart';

import 'core/core.dart';
import 'data/data.dart';
import 'firebase_options.dart';
import 'i18n/strings.g.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await dotenv.load();
  await setupDependencies();

  // Preload SVGs
  await preloadSVGs([
    'assets/flags/ru.svg',
    'assets/flags/en.svg',
  ]);
  // Load timeago locales
  timeago.setLocaleMessages('ru', timeago.RuMessages());
  timeago.setLocaleMessages('en', timeago.EnMessages());

  // Setup the locale for the app
  final settingsRepository = getIt<SettingsRepository>();
  final languageCode = settingsRepository.getLanguageCode();
  LocaleSettings.setLocaleRaw(languageCode);

  // Configure application settings based on the target platform
  if (AppTheme.isMobile) {
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
    await SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.immersiveSticky,
    );
  } else if (defaultTargetPlatform == TargetPlatform.windows) {
    await windowManager.ensureInitialized();

    const windowOptions = WindowOptions(
      backgroundColor: Colors.transparent,
      skipTaskbar: false,
      title: 'Shinga',
      size: Size(420, 720),
    );

    await windowManager.waitUntilReadyToShow(windowOptions, () async {
      await windowManager.show();
      await windowManager.focus();
      // await windowManager.setResizable(false);
      await windowManager.setMaximizable(false);
    });
  }

  runApp(
    TranslationProvider(
      child: const MainApp(),
    ),
  );
}
