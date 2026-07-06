import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'package:shinga/core/core.dart';
import 'package:shinga/features/features.dart';

/// The shell page for the home feature.
///
/// Selects between [HomeWideLayout] and [HomeNarrowLayout] based on the
/// current breakpoint and renders the active tab via [AutoTabsRouter].
@RoutePage()
class HomeShellPage extends StatelessWidget {
  /// Creates a [HomeShellPage] widget.
  const HomeShellPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<FavoritesBloc>(
          create: (context) => FavoritesBloc(context.deps.titleRepository),
        ),
      ],
      child: AutoTabsRouter(
        routes: [
          FavoritesRoute(),
          const ProfileRoute(),
          const SettingsRoute(),
        ],
        builder: (context, child) {
          final tabsRouter = AutoTabsRouter.of(context);

          if (ResponsiveBreakpoints.of(context).largerThan(MOBILE)) {
            return HomeWideLayout(tabsRouter: tabsRouter, child: child);
          } else {
            return HomeNarrowLayout(tabsRouter: tabsRouter, child: child);
          }
        },
      ),
    );
  }
}
