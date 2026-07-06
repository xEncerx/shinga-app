import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shinga/domain/domain.dart';
import 'package:shinga/features/profile/bloc/bloc.dart';
import 'package:shinga/features/profile/widgets/widgets.dart';
import 'package:shinga/i18n/extensions/extensions.dart';
import 'package:shinga/i18n/strings.g.dart';
import 'package:ui_kit/ui_kit.dart';

/// Error state for profile loading failures.
class ProfileErrorState extends StatelessWidget {
  /// Creates a [ProfileErrorState] widget.
  const ProfileErrorState({required this.failure, super.key, this.initialUser});

  /// Failure returned while loading profile data.
  final AppFailure failure;

  /// User from the active session, if available.
  final UserEntity? initialUser;

  @override
  Widget build(BuildContext context) {
    final t = Translations.of(context);
    final message = failure.toMessage();
    final user = initialUser;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.l),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 500),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: AppSpacing.l,
            children: [
              if (user != null) ProfileHeaderCard(user: user),
              SaStateMessage.error(
                title: message.title,
                description: message.description,
                buttonText: t.profile.state.retry,
                onPressed: () => context.read<UserProfileBloc>().add(
                  const UserProfileRefreshRequested(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
