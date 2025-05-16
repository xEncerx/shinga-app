import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

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

  // Setup the locale for the app
  final settingsRepository = getIt<SettingsRepository>();
  final languageCode = settingsRepository.getLanguageCode();
  LocaleSettings.setLocaleRaw(languageCode);

  runApp(
    TranslationProvider(
      child: const MainApp(),
    ),
  );
}
