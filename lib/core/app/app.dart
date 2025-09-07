import 'dart:ui';

import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:responsive_framework/responsive_framework.dart';

import '../../data/data.dart';
import '../../features/features.dart';
import '../../i18n/strings.g.dart';
import '../core.dart';

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    final appRouter = getIt<AppRouter>();

    return BlocProvider(
      create: (_) => SettingsCubit(getIt<AppSettings>()),
      child: BlocSelector<SettingsCubit, SettingsState, (ThemeMode, FlexScheme)>(
        selector: (state) => (state.settings.theme, state.settings.colorScheme),
        builder: (context, themeData) {
          final (themeMode, colorScheme) = themeData;

          return MaterialApp.router(
            title: 'Shinga',
            locale: TranslationProvider.of(context).flutterLocale,
            supportedLocales: AppLocaleUtils.supportedLocales,
            localizationsDelegates: GlobalMaterialLocalizations.delegates,
            theme: AppTheme.lightTheme(scheme: colorScheme),
            darkTheme: AppTheme.darkTheme(scheme: colorScheme),
            themeMode: themeMode,
            debugShowCheckedModeBanner: false,
            scrollBehavior: const MyCustomScrollBehavior(),
            routerConfig: appRouter.config(),
            builder: (_, child) => ResponsiveBreakpoints.builder(
              child: child!,
              breakpoints: [
                const Breakpoint(start: 0, end: 450, name: MOBILE),
                const Breakpoint(start: 451, end: 800, name: TABLET),
                const Breakpoint(start: 801, end: 1920, name: DESKTOP),
                const Breakpoint(start: 1921, end: double.infinity, name: '4K'),
              ],
            ),
          );
        },
      ),
    );
  }
}

/// Custom scroll behavior that enables both touch and mouse input.
///
/// Enhances the default scroll behavior by supporting additional pointer devices.
class MyCustomScrollBehavior extends MaterialScrollBehavior {
  const MyCustomScrollBehavior();

  /// Defines which pointer devices can initiate drag gestures.
  @override
  Set<PointerDeviceKind> get dragDevices => {
    PointerDeviceKind.touch,
    PointerDeviceKind.mouse,
    PointerDeviceKind.trackpad,
  };
}
