import 'package:auto_route/auto_route.dart';
import 'package:get_it/get_it.dart';

import '../../data/data.dart';
import 'app_router.dart';

/// Guard that protects routes requiring authentication.
///
/// Redirects unauthenticated users to the auth route.
class AuthGuard extends AutoRouteGuard {
  /// Checks authentication status before allowing navigation.
  ///
  /// If authenticated, allows navigation to continue.
  /// If not authenticated, redirects to the auth route.
  @override
  Future<void> onNavigation(NavigationResolver resolver, StackRouter router) async {
    final isAuth = await GetIt.I<SecureStorageDatasource>().getToken();
    if (isAuth != null){
      resolver.next();
    } else {
      router.push(const AuthRoute());
      resolver.next(false);
    }
  }
}
