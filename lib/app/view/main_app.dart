import 'dart:async';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'package:shinga/core/core.dart';
import 'package:shinga/domain/domain.dart';
import 'package:shinga/features/features.dart';
import 'package:shinga/i18n/strings.g.dart';
import 'package:ui_kit/ui_kit.dart';

/// The root widget and entrypoint of the application.
///
/// Builds [MaterialApp.router] and is responsible for:
/// - Registering long-lived blocs.
/// - Configuring theming, routing, and localization.
/// - Wrapping the widget tree in [AuthShell] and responsive breakpoints.
class MainApp extends StatelessWidget {
  /// Creates a [MainApp] widget.
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    final t = TranslationProvider.of(context);
    final deps = Dependencies.of(context);

    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => SessionBloc(
            authRepository: deps.authRepository,
            sessionRepository: deps.sessionRepository,
            logger: deps.logger,
          )..add(SessionStarted()),
        ),
        BlocProvider(
          create: (_) {
            final cubit = AppSettingsCubit(deps.appSettingsRepository);
            unawaited(cubit.loadSettings());
            return cubit;
          },
        ),
      ],
      child: BlocSelector<AppSettingsCubit, AppSettingsState, (AppThemeMode, AppColorScheme)>(
        selector: (state) => (state.settings.themeMode, state.settings.colorScheme),
        builder: (context, themeSettings) => MaterialApp.router(
          title: t.translations.appName,
          theme: AppTheme.lightTheme(scheme: themeSettings.$2.toColorScheme()),
          darkTheme: AppTheme.darkTheme(scheme: themeSettings.$2.toColorScheme()),
          themeMode: themeSettings.$1.toThemeMode(),
          locale: t.flutterLocale,
          supportedLocales: AppLocaleUtils.supportedLocales,
          localizationsDelegates: GlobalMaterialLocalizations.delegates,
          routerConfig: deps.appRouter.config(),
          scrollBehavior: const MyCustomScrollBehavior(),
          debugShowCheckedModeBanner: false,
          builder: (_, child) => AuthShell(
            child: ResponsiveBreakpoints.builder(
              breakpoints: [
                const Breakpoint(start: 0, end: 599, name: MOBILE),
                const Breakpoint(start: 600, end: 839, name: TABLET),
                const Breakpoint(start: 840, end: 1920, name: DESKTOP),
              ],
              child: child!,
            ),
          ),
        ),
      ),
    );
  }
}

/// Custom scroll behavior that enables both touch and mouse input.
///
/// Enhances the default scroll behavior by supporting additional pointer devices.
class MyCustomScrollBehavior extends MaterialScrollBehavior {
  /// Creates a [MyCustomScrollBehavior] instance.
  const MyCustomScrollBehavior();

  /// Defines which pointer devices can initiate drag gestures.
  @override
  Set<PointerDeviceKind> get dragDevices => {
    PointerDeviceKind.touch,
    PointerDeviceKind.mouse,
    PointerDeviceKind.trackpad,
  };
}
