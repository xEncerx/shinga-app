import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'package:shinga/core/core.dart';
import 'package:shinga/domain/domain.dart';
import 'package:shinga/features/auth/auth.dart';
import 'package:shinga/features/profile/bloc/bloc.dart';
import 'package:shinga/features/profile/view/layouts/layouts.dart';
import 'package:shinga/features/profile/widgets/widgets.dart';

/// The profile page displaying user information and reading statistics.
@RoutePage()
class ProfilePage extends StatelessWidget {
  /// Creates a [ProfilePage] widget.
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final initialUser = context.select<SessionBloc, UserEntity?>((bloc) {
      final state = bloc.state;
      return state is SessionAuthenticated ? state.session.user : null;
    });

    return BlocProvider(
      create: (context) => UserProfileBloc(
        userRepository: context.deps.userRepository,
      )..add(UserProfileStarted(initialUser: initialUser)),
      child: const Scaffold(
        body: SafeArea(child: _ProfileView()),
      ),
    );
  }
}

class _ProfileView extends StatelessWidget {
  const _ProfileView();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<UserProfileBloc, UserProfileState>(
      builder: (context, state) {
        return switch (state) {
          UserProfileLoaded(:final user, :final statistics, :final isRefreshing) =>
            ResponsiveBreakpoints.of(context).largerThan(TABLET)
                ? ProfileWideLayout(
                    user: user,
                    statistics: statistics,
                    isRefreshing: isRefreshing,
                  )
                : ProfileNarrowLayout(
                    user: user,
                    statistics: statistics,
                    isRefreshing: isRefreshing,
                  ),
          UserProfileLoading(:final initialUser) => ProfileLoadingPlaceholder(
            initialUser: initialUser,
          ),
          UserProfileFailure(:final failure, :final initialUser) => ProfileErrorState(
            failure: failure,
            initialUser: initialUser,
          ),
          UserProfileInitial() => const ProfileLoadingPlaceholder(),
        };
      },
    );
  }
}
