import 'package:auto_route/auto_route.dart';
import 'package:flutter/foundation.dart' show Key;
import 'package:shinga/core/core.dart';
import 'package:shinga/domain/domain.dart';
import 'package:shinga/features/features.dart';

part 'app_router.gr.dart';

/// The main application router using AutoRoute for navigation.
@AutoRouterConfig()
class AppRouter extends RootStackRouter {
  @override
  List<AutoRoute> get routes => [
    AutoRoute(
      page: HomeShellRoute.page,
      path: '/',
      children: [
        AutoRoute(
          page: FavoritesRoute.page,
          path: 'favorites',
          initial: true,
        ),
        AutoRoute(page: ProfileRoute.page, path: 'profile'),
        AutoRoute(
          page: SettingsRoute.page,
          path: 'settings',
          children: [
            AutoRoute(page: SettingsMainRoute.page, initial: true),
            AutoRoute(page: SettingsAppearanceRoute.page),
            AutoRoute(page: SettingsReadingRoute.page),
            AutoRoute(page: SettingsCacheRoute.page),
            AutoRoute(page: SettingsAboutRoute.page),
            AutoRoute(page: SettingsAdBlockerRoute.page),
          ],
        ),
      ],
    ),
    AutoRoute(page: TitleSearchRoute.page, path: '/search'),
    AutoRoute(page: LoggerRoute.page, path: '/logger'),
    AutoRoute(page: TitleDetailRoute.page, path: '/title'),
    AutoRoute(page: WebviewReaderRoute.page, path: '/reader'),
    AutoRoute(page: SettingsAdBlockerRoute.page, path: '/adblocker-settings'),
    AutoRoute(
      page: AuthRoute.page,
      path: '/auth',
      children: [
        AutoRoute(page: LoginRoute.page, path: 'login', initial: true),
        AutoRoute(page: SignUpRoute.page, path: 'signup'),
        AutoRoute(page: PasswordResetRoute.page, path: 'password-reset'),
      ],
    ),
  ];
}
