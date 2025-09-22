import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/core.dart';
import '../../../data/data.dart';
import '../../../i18n/strings.g.dart';
import '../../features.dart';

class TitleSelectableRating extends StatefulWidget {
  const TitleSelectableRating({
    super.key,
    required this.titleData,
  });

  final TitleWithUserData titleData;

  @override
  State<TitleSelectableRating> createState() => _TitleSelectableRatingState();
}

class _TitleSelectableRatingState extends State<TitleSelectableRating>
    with TickerProviderStateMixin {
  late final AnimationController _shimmerController;
  late final Animation<double> _shimmerAnimation;

  bool _isExpanded = false;
  late int _currentRating;

  @override
  void initState() {
    super.initState();
    _currentRating = widget.titleData.userData?.userRating ?? 0;

    _shimmerController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat();

    _shimmerAnimation = Tween<double>(begin: -1, end: 1).animate(
      CurvedAnimation(
        parent: _shimmerController,
        curve: Curves.linear,
      ),
    );
  }

  @override
  void dispose() {
    _shimmerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          GestureDetector(
            onTap: () => setState(() => _isExpanded = !_isExpanded),
            child: Row(
              children: [
                const IconContainer(
                  icon: Icons.star_rate_rounded,
                  backgroundOpacity: 0.1,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    t.titleInfo.yourRating,
                    style: theme.textTheme.titleMedium.semiBold.withColor(
                      theme.colorScheme.onSurface,
                    ),
                  ),
                ),
                if (_currentRating > 0) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '$_currentRating/10',
                      style: theme.textTheme.bodySmall.semiBold.withColor(
                        theme.colorScheme.onPrimary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                ],
                AnimatedRotation(
                  turns: _isExpanded ? 0.5 : 0,
                  duration: const Duration(milliseconds: 200),
                  child: Icon(
                    Icons.keyboard_arrow_down,
                    color: theme.colorScheme.outline,
                  ),
                ),
              ],
            ),
          ).clickable,
          AnimatedSize(
            duration: const Duration(milliseconds: 200),
            child: _isExpanded
                ? Padding(
                    padding: const EdgeInsets.only(top: 16),
                    child: Column(
                      spacing: 16,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            ...List.generate(
                              10,
                              (index) {
                                index++;
                                return GestureDetector(
                                  onTap: () => _setRating(index),
                                  child: _RatingStar(
                                    shimmerAnimation: _shimmerAnimation,
                                    starIndex: index,
                                    isSelected: _currentRating >= index,
                                  ),
                                ).clickable;
                              },
                            ),
                          ],
                        ),
                        Row(
                          spacing: 15,
                          children: [
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: _resetRating,
                                icon: const Icon(Icons.clear),
                                label: Text(t.common.reset),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: theme.colorScheme.outline,
                                ),
                              ),
                            ),
                            Expanded(
                              child: FilledButton.icon(
                                onPressed: _currentRating > 0 ? () => _saveRating() : null,
                                icon: const Icon(Icons.save),
                                label: Text(t.common.save),
                                style: FilledButton.styleFrom(
                                  backgroundColor: theme.colorScheme.primary,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }

  void _setRating(int rating) {
    setState(() => _currentRating = rating);
  }

  void _resetRating() {
    setState(() => _currentRating = 0);
    _saveRating();
  }

  void _saveRating() {
    final userData = widget.titleData.userData;

    if (userData != null && userData.userRating != _currentRating) {
      context.read<TitleInfoBloc>().add(
        UpdateTitleDataEvent(
          titleData: widget.titleData,
          userRating: _currentRating,
        ),
      );
    }
  }
}

/// A single star widget that can be either filled or outlined, with a shimmer effect when filled.
class _RatingStar extends StatelessWidget {
  const _RatingStar({
    required this.starIndex,
    required this.isSelected,
    required this.shimmerAnimation,
  });

  /// The index of the star (1-10).
  final int starIndex;

  /// Whether the star is selected (filled) or not (outlined).
  final bool isSelected;

  /// The animation for the shimmer effect.
  final Animation<double> shimmerAnimation;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Stack(
      children: [
        Icon(
          isSelected ? Icons.star_rounded : Icons.star_border_rounded,
          size: 28,
          color: isSelected ? _getStarColor(starIndex) : theme.colorScheme.outline,
        ),
        if (isSelected)
          AnimatedBuilder(
            animation: shimmerAnimation,
            builder: (context, child) {
              return ShaderMask(
                shaderCallback: (bounds) {
                  return LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    stops: [
                      (shimmerAnimation.value - 0.2).clamp(0, 1),
                      shimmerAnimation.value.clamp(0, 1),
                      (shimmerAnimation.value + 0.2).clamp(0, 1),
                    ],
                    colors: [
                      Colors.white.withValues(alpha: 0),
                      Colors.white.withValues(alpha: 0.5),
                      Colors.white.withValues(alpha: 0),
                    ],
                  ).createShader(bounds);
                },
                child: const Icon(
                  Icons.star_rounded,
                  size: 28,
                  color: Colors.white,
                ),
              );
            },
          ),
      ],
    );
  }

  /// Returns a color based on the rating value.
  static Color _getStarColor(int rating) {
    final ratio = rating / 9;

    switch (ratio) {
      case (< 0.33):
        return Color.lerp(
          Colors.red.shade400,
          Colors.orange.shade300,
          ratio / 0.33,
        )!;
      case (< 0.67):
        return Color.lerp(
          Colors.orange.shade300,
          Colors.yellow.shade600,
          (ratio - 0.33) / 0.33,
        )!;
      default:
        return Color.lerp(
          Colors.yellow.shade600,
          Colors.green.shade400,
          (ratio - 0.66) / 0.34,
        )!;
    }
  }
}
