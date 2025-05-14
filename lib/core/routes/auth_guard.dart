import 'package:auto_route/auto_route.dart';
import 'package:get_it/get_it.dart';

import '../../data/data.dart';
import 'app_router.dart';

class AuthGuard extends AutoRouteGuard {
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
