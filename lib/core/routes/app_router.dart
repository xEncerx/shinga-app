import 'dart:typed_data';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';

import '../../data/data.dart';
import '../../features/features.dart';
import 'routes.dart';

part 'app_router.gr.dart';

/// Application router configuration using auto_route.
///
/// Defines all navigation routes for the application.
@AutoRouterConfig()
class AppRouter extends RootStackRouter {
  /// Creates an application router.
  AppRouter({super.navigatorKey});

  /// The list of defined routes in the application.
  @override
  List<AutoRoute> get routes => [
    AutoRoute(
      page: MainRoute.page,
      initial: true,
      path: '/',
      guards: [AuthGuard()],
      children: [
        AutoRoute(
          page: FavoritesRoute.page,
          initial: true,
          path: 'favorites',
        ),
        AutoRoute(
          page: AutoProfileRoute.page,
          children: [
            AutoRoute(
              page: ProfileRoute.page,
              path: 'profile',
              initial: true,
            ),
            AutoRoute(
              page: CropAvatarRoute.page,
              path: 'crop-avatar',
            ),
          ],
        ),
        AutoRoute(
          page: AutoSettingsRoute.page,
          path: 'settings',
          children: [
            AutoRoute(
              page: SettingsRoute.page,
              path: '',
              initial: true,
            ),
            AutoRoute(
              page: AboutApplicationRoute.page,
              path: 'about',
            ),
          ],
        ),
      ],
    ),
    AutoRoute(
      page: SearchRoute.page,
      path: '/search',
      guards: [AuthGuard()],
    ),
    AutoRoute(
      page: TitleInfoRoute.page,
      path: '/title-info',
      guards: [AuthGuard()],
    ),
    // ignore: inference_failure_on_instance_creation
    CustomRoute(
      page: WebViewReaderRoute.page,
      path: '/title-reader',
      guards: [AuthGuard()],
      transitionsBuilder: TransitionsBuilders.noTransition,
    ),
    AutoRoute(
      page: AuthRoute.page,
      children: [
        AutoRoute(
          page: SignInRoute.page,
          path: 'sign-in',
          initial: true,
        ),
        AutoRoute(
          page: SignUpRoute.page,
          path: 'sign-up',
        ),
        AutoRoute(
          page: ResetPasswordRoute.page,
          path: 'reset-password',
        ),
      ],
    ),
  ];
}
