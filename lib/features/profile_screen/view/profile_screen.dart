import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../../core/core.dart';
import '../../../data/data.dart';
import '../../../i18n/strings.g.dart';
import '../../features.dart';

@RoutePage()
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    context.read<ProfileBloc>().add(LoadUserProfile());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final t = Translations.of(context);

    return Scaffold(
      body: SafeArea(
        child: BlocBuilder<ProfileBloc, ProfileState>(
          builder: (context, state) {
            final isLoading = state is ProfileLoading;
            if (state is ProfileFailure) {
              return ShowInfoWidget.error(
                title: state.error.error ?? t.errors.errorOccurred,
                description: state.error.detail,
                onRetry: () => context.read<ProfileBloc>().add(LoadUserProfile()),
              );
            }

            final userData = state is ProfileLoaded ? state.userData : UserData.dummy;
            final userVotes = state is ProfileLoaded ? state.userVotes : UserVotes.dummy;

            return Skeletonizer(
              enabled: isLoading,
              child: CustomScrollView(
                slivers: [
                  SliverAppBar(
                    expandedHeight: 150,
                    backgroundColor: Colors.transparent,
                    elevation: 0,
                    flexibleSpace: FlexibleSpaceBar(
                      background: Stack(
                        children: [
                          Skeleton.keep(
                            child: Container(
                              height: 100,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    theme.colorScheme.primary.withOpacity(0.6),
                                    theme.colorScheme.primary.withOpacity(0.9),
                                    theme.colorScheme.primary,
                                    theme.colorScheme.primary.withOpacity(0.9),
                                    theme.colorScheme.primary.withOpacity(0.6),
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                              ),
                            ),
                          ),
                          Align(
                            alignment: Alignment.bottomCenter,
                            child: UserAvatar(avatarUrl: userData.avatar.fullUrl),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: Column(
                      spacing: 10,
                      children: [
                        const SizedBox(height: 0),
                        Text(
                          userData.username,
                          style: theme.textTheme.titleLarge.semiBold,
                        ),
                        if (userData.isStaff || userData.isSuperuser) ...[
                          Row(
                            spacing: 10,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              if (userData.isSuperuser)
                                Chip(
                                  label: Text(t.profile.admin),
                                ),
                              if (userData.isStaff)
                                Chip(
                                  label: Text(t.profile.staff),
                                ),
                            ],
                          ),
                        ],
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            StatisticItem(
                              icon: Icons.star_rounded,
                              value: userData.avgRating.toStringAsFixed(1),
                              label: t.profile.stats.rating,
                            ),
                            StatisticItem(
                              icon: Icons.thumb_up_alt_rounded,
                              value: userData.countLikes.toString(),
                              label: t.profile.stats.likes,
                            ),
                            StatisticItem(
                              icon: Icons.poll_rounded,
                              value: userData.countVotes.toString(),
                              label: t.profile.stats.votes,
                            ),
                          ],
                        ),
                        UserCharts(
                          userData: userData,
                          userVotes: userVotes,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
