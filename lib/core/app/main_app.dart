import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:get_it/get_it.dart';
import 'package:responsive_framework/responsive_framework.dart';

import '../../cubit/cubit.dart';
import '../../features/features.dart';
import '../../i18n/strings.g.dart';
import '../core.dart';

/// Main application widget that configures the app environment.
///
/// Sets up routing, themes, localization, and state management.
class MainApp extends StatelessWidget {
  /// Creates the main application container.
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    final appRouter = getIt<AppRouter>();

    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => GetIt.I<AuthBloc>()),
        BlocProvider(create: (context) => GetIt.I<FavoriteBloc>()),
        BlocProvider(create: (context) => GetIt.I<AppSettingsCubit>()),
        BlocProvider(create: (context) => GetIt.I<SearchingBloc>()),
      ],
      child: BlocSelector<AppSettingsCubit, AppSettingsState, bool>(
        selector: (state) => state.appSettings.isDarkTheme,
        builder: (context, isDarkTheme) {
          return MaterialApp.router(
            locale: TranslationProvider.of(context).flutterLocale,
            supportedLocales: AppLocaleUtils.supportedLocales,
            localizationsDelegates: GlobalMaterialLocalizations.delegates,
            theme: AppTheme.lightTheme(),
            darkTheme: AppTheme.darkTheme(),
            themeMode: isDarkTheme ? ThemeMode.dark : ThemeMode.light,
            debugShowCheckedModeBanner: false,
            title: "Shinga",
            routerConfig: appRouter.config(),
            scrollBehavior: MyCustomScrollBehavior(),
            builder: (_, child) => ResponsiveBreakpoints.builder(
              child: ResponsiveScaledBox(
                width: 450,
                child: child!,
              ),
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
  /// Defines which pointer devices can initiate drag gestures.
  @override
  Set<PointerDeviceKind> get dragDevices => {
    PointerDeviceKind.touch,
    PointerDeviceKind.mouse,
  };
}
