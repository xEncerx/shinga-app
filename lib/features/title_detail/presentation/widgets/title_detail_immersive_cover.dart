import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shinga/core/core.dart';
import 'package:shinga/features/features.dart';

/// A widget that displays an immersive cover image for a title.
class TitleDetailImmersiveCover extends StatelessWidget {
  /// Creates a [TitleDetailImmersiveCover] widget.
  const TitleDetailImmersiveCover({super.key});

  @override
  Widget build(BuildContext context) {
    final bg = Theme.of(context).scaffoldBackgroundColor;

    return BlocSelector<TitleDetailCubit, TitleDetailState, String>(
      selector: (state) => state.data.title.cover.original.toAbsoluteUrl(),
      builder: (_, coverUrl) {
        return RepaintBoundary(
          child: Stack(
            fit: StackFit.expand,
            children: [
              TitleCover(
                coverUrl: coverUrl,
                borderRadius: BorderRadius.zero,
                opacity: 0.2,
                // fit: BoxFit.fill,
              ),
              DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    stops: const [0, 0.5],
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [bg, bg.withValues(alpha: 0)],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
