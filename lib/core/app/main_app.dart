import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:get_it/get_it.dart';

import '../../cubit/cubit.dart';
import '../../features/features.dart';
import '../../i18n/strings.g.dart';
import '../core.dart';

class MainApp extends StatelessWidget {
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
          );
        },
      ),
    );
  }
}

class MyCustomScrollBehavior extends MaterialScrollBehavior {
  @override
  Set<PointerDeviceKind> get dragDevices => {
        PointerDeviceKind.touch,
        PointerDeviceKind.mouse,
      };
}
