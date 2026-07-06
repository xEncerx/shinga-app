import 'package:flutter/material.dart';
import 'package:shinga/domain/domain.dart';
import 'package:shinga/features/profile/widgets/widgets.dart';
import 'package:ui_kit/ui_kit.dart';

/// Loading placeholder for the profile screen.
class ProfileLoadingPlaceholder extends StatelessWidget {
  /// Creates a [ProfileLoadingPlaceholder] widget.
  const ProfileLoadingPlaceholder({super.key, this.initialUser});

  /// User from the active session, if available while fresh data is loading.
  final UserEntity? initialUser;

  @override
  Widget build(BuildContext context) {
    final user = initialUser;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.l),
      child: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: AppSpacing.l,
          children: [
            if (user != null) ProfileHeaderCard(user: user) else const _ShimmerBlock(height: 200),
            const _ShimmerBlock(height: 120),
            const _ShimmerBlock(height: 300),
          ],
        ),
      ),
    );
  }
}

class _ShimmerBlock extends StatelessWidget {
  const _ShimmerBlock({required this.height});

  final double height;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppRadius.card),
      child: SizedBox(
        height: height,
        child: const SaShimmer(),
      ),
    );
  }
}
