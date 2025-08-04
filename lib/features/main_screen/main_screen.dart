import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/core.dart';
import '../../data/data.dart';
import '../../i18n/strings.g.dart';
import '../features.dart';

/// Main screen of the application that serves as the entry point
/// after authentication.
@RoutePage()
class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final t = Translations.of(context);

    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => ProfileBloc(restClient: getIt<RestClient>()),
        ),
        BlocProvider(
          create: (_) => FavoritesBloc(restClient: getIt<RestClient>()),
        ),
      ],
      child: AutoTabsScaffold(
        routes: [
          FavoritesRoute(),
          const ProfileRoute(),
          const SettingsRoute(),
        ],
        bottomNavigationBuilder: (context, tabsRouter) {
          return BottomNavigationBar(
            currentIndex: tabsRouter.activeIndex,
            onTap: tabsRouter.setActiveIndex,
            items: [
              BottomNavigationBarItem(
                icon: const Icon(Icons.favorite),
                label: t.favorites.title,
              ),
              BottomNavigationBarItem(
                icon: const Icon(Icons.person),
                label: t.profile.title,
              ),
              BottomNavigationBarItem(
                icon: const Icon(Icons.settings),
                label: t.settings.title,
              ),
            ],
          );
        },
      ),
    );
  }
}
