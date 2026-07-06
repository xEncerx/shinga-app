import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shinga/features/features.dart';
import 'package:ui_kit/ui_kit.dart';

/// Displays an overlay menu in the title detail screen, providing options for users to change their bookmark status and rating for a title.
Future<void> showTitleDetailMenuOverlay(BuildContext context) async {
  await showGeneralDialog(
    context: context,
    barrierColor: Theme.of(context).scaffoldBackgroundColor.withValues(alpha: 0.7),
    pageBuilder: (_, _, _) => BlocProvider.value(
      value: context.read<TitleDetailCubit>(),
      child: const TitleDetailMenuOverlay(),
    ),
  );
}

/// The overlay widget that contains bookmark actions and the rating slider.
class TitleDetailMenuOverlay extends StatelessWidget {
  /// Creates a [TitleDetailMenuOverlay] widget.
  const TitleDetailMenuOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: Column(
        spacing: AppSpacing.s,
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          const Padding(
            // FAB size = 56, Bookmark ActionButton size = 48
            // So padding = (FAB size - ActionButton size) / 2 = (56 - 48) / 2 = 4
            padding: EdgeInsets.only(right: 4),
            child: TitleDetailBookmarkActions(),
          ),
          Row(
            spacing: AppSpacing.s,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Padding(
                padding: EdgeInsets.only(left: AppSpacing.m),
                child: TitleDetailRatingSlider(),
              ),
              SaFloatingActionButton(
                onPressed: () => context.router.pop(),
                child: const SaIcon(
                  icon: SaIconSource.huge(HugeIconsStrokeRounded.cancel01),
                ),
              ),
            ],
          ),
        ],
      ),
      // Dismiss Area: Detects taps outside the menu to dismiss the overlay.
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => context.router.pop(),
        child: const SizedBox.expand(),
      ),
    );
  }
}
