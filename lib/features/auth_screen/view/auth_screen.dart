import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:responsive_framework/responsive_framework.dart';

import '../../../core/core.dart';
import '../../../data/data.dart';
import '../../../utils/utils.dart';
import '../../features.dart';

/// Screen for user authentication (login/signup).
@RoutePage()
class AuthScreen extends StatelessWidget {
  const AuthScreen({super.key});

  static final GlobalKey _authContainerKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => AuthBloc(
        restClient: getIt<RestClient>(),
        secureStorageRepo: getIt<SecureStorageRepository>(),
      ),
      child: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthSuccess) {
            showSnackBar(context, state.message);
            // If user is signed in successfully, navigate to the main route
            if (state is AuthSignInSuccess) {
              context.router.replaceAll([const MainRoute()]);
            }
          } else if (state is AuthFailure) {
            showSnackBar(context, state.error.detail);
          }
        },
        child: Scaffold(
          body: SafeArea(
            child: Center(
              child: Container(
                padding: const EdgeInsets.all(20),
                constraints: const BoxConstraints(
                  maxHeight: 650,
                  minHeight: 400,
                ),
                child: ResponsiveBreakpoints.of(context).largerOrEqualTo(DESKTOP)
                    ? Row(
                        spacing: 40,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Flexible(child: AppDetail()),
                          Flexible(
                            child: DefaultAuthContainer(
                              key: _authContainerKey,
                            ),
                          ),
                        ],
                      )
                    : DefaultAuthContainer(
                        key: _authContainerKey,
                      ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class DefaultAuthContainer extends StatelessWidget {
  const DefaultAuthContainer({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ClipRRect(
      borderRadius: BorderRadiusGeometry.circular(20),
      child: Container(
        constraints: const BoxConstraints(
          minWidth: 500,
          maxWidth: 700,
        ),
        foregroundDecoration: BoxDecoration(
          border: Border.all(
            width: 2,
            color: theme.dividerColor,
          ),
          borderRadius: BorderRadius.circular(19),
        ),
        child: AutoTabsRouter(
          routes: const [
            SignInRoute(),
            SignUpRoute(),
            ResetPasswordRoute(),
          ],
          builder: (context, child) {
            final tabRouter = AutoTabsRouter.of(context);

            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                AuthNavigationRail(
                  currentIndex: tabRouter.activeIndex,
                  onTap: (index) => tabRouter.setActiveIndex(index),
                ),
                const VerticalDivider(width: 0, thickness: 2),
                Flexible(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: child,
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
