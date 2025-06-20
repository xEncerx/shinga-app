import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';

import '../../data/data.dart';
import '../../features/features.dart';
import 'auth_guard.dart';
part 'app_router.gr.dart';

/// Application router configuration using auto_route.
///
/// Defines all navigation routes for the application.
@AutoRouterConfig()
class AppRouter extends RootStackRouter {
  /// Creates an application router.
  AppRouter({super.navigatorKey});
  
  /// The list of defined routes in the application.
  ///
  /// Includes routes for authentication, favorites, settings, search, 
  /// manga information and reading view.
  @override
  List<AutoRoute> get routes => [
        AutoRoute(
          page: FavoriteRoute.page,
          path: "/",
          guards: [AuthGuard()],
          initial: true,
        ),
        AutoRoute(
          page: AuthRoute.page,
          children: [
            AutoRoute(page: SignInRoute.page, path: "sign-in", initial: true),
            AutoRoute(page: SignUpRoute.page, path: "sign-up"),
          ],
        ),
        AutoRoute(
          page: SettingsRoute.page,
          path: "/settings",
        ),
        AutoRoute(
          page: SearchingRoute.page,
          path: "/search",
        ),
        AutoRoute(
          page: MangaInfoRoute.page,
          path: "/manga-info",
        ),
        AutoRoute(
          page: ReadingWebViewRoute.page,
          path: "/reading-webview",
        ),
      ];
}
