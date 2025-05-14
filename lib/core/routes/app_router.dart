import 'package:auto_route/auto_route.dart';

import '../../features/features.dart';
import 'auth_guard.dart';
part 'app_router.gr.dart';

@AutoRouterConfig()
class AppRouter extends RootStackRouter {
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
      ];
}
