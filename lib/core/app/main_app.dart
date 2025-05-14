import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

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
        BlocProvider(create: (context) => AuthBloc()),
        BlocProvider(create: (context) => FavoriteBloc()),
        BlocProvider(create: (context) => AppSettingsCubit()),
      ],
      child: BlocSelector<AppSettingsCubit, AppSettingsState, bool>(
        selector: (state) => state.appSettings.isDarkTheme,
        builder: (context, isDarkTheme) {
          return MaterialApp.router(
            locale: TranslationProvider.of(context).flutterLocale,
            supportedLocales: AppLocaleUtils.supportedLocales,
            localizationsDelegates: GlobalMaterialLocalizations.delegates,
            theme: AppTheme.darkTheme(),
            darkTheme: AppTheme.darkTheme(),
            themeMode: isDarkTheme ? ThemeMode.dark : ThemeMode.light,
            debugShowCheckedModeBanner: false,
            title: "Shinga",
            routerConfig: appRouter.config(),
          );
        },
      ),
    );
  }
}
