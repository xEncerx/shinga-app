import 'package:flutter/material.dart';
import 'package:ui_kit/src/src.dart';

/// A card-based selector widget that allows users to choose from a set of options.
class SaCardSelector<T> extends StatelessWidget {
  /// Creates a [SaCardSelector] widget.
  const SaCardSelector({
    required this.items,
    required this.selected,
    required this.onChanged,
    this.optionWidth,
    this.optionHeight,
    this.selectedColor,
    this.unselectedColor,
    super.key,
  });

  /// The list of items to display in the selector.
  final List<SaCardSelectorItem<T>> items;

  /// The currently selected value.
  final T selected;

  /// Callback function that is called when the selected value changes.
  final ValueChanged<T> onChanged;

  /// The width of each option in the selector. If not provided, it will be calculated based on the available space and the number of items.
  final double? optionWidth;

  /// The height of the selector. If not provided, it will be determined by the content.
  final double? optionHeight;

  /// The color used for the selected option. If not provided, it defaults to the primary color of the theme.
  final Color? selectedColor;

  /// The color used for unselected options. If not provided, it defaults to the onSurfaceVariant color of the theme.
  final Color? unselectedColor;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final optionWidth = this.optionWidth ?? (constraints.maxWidth / items.length) * 0.8;

        final itemCount = items.length;
        final totalGaps = itemCount + 1;
        final freeSpace = constraints.maxWidth - (optionWidth * itemCount);
        final gap = freeSpace / totalGaps;
        final selectedIndex = items.indexWhere((item) => item.value == selected);
        final validSelectedIndex = selectedIndex >= 0 ? selectedIndex : 0;
        final leftPosition = gap + (validSelectedIndex * (optionWidth + gap));

        final effectiveSelectedColor = selectedColor ?? context.colors.primary;
        final effectiveUnselectedColor = unselectedColor ?? context.colors.onSurfaceVariant;
        return SizedBox(
          height: optionHeight,
          child: Stack(
            alignment: Alignment.center,
            children: [
              _SlidingSelectionIndicator(
                leftPosition: leftPosition,
                width: optionWidth,
                color: effectiveSelectedColor,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: items
                    .map(
                      (item) => _SaCardSelectorOption<T>(
                        item: item,
                        isSelected: selected == item.value,
                        onTap: () => onChanged(item.value),
                        width: optionWidth,
                        selectedColor: effectiveSelectedColor,
                        unselectedColor: effectiveUnselectedColor,
                      ),
                    )
                    .toList(),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _SlidingSelectionIndicator extends StatelessWidget {
  const _SlidingSelectionIndicator({
    required this.leftPosition,
    required this.width,
    required this.color,
  });

  final double leftPosition;
  final double width;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return AnimatedPositioned(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOutCubic,
      left: leftPosition,
      top: 0,
      bottom: 0,
      width: width,
      child: IgnorePointer(
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.card),
            border: Border.all(
              color: color,
              width: 2,
            ),
            color: color.withValues(alpha: 0.1),
          ),
        ),
      ),
    );
  }
}

class _SaCardSelectorOption<T> extends StatelessWidget {
  const _SaCardSelectorOption({
    required this.item,
    required this.isSelected,
    required this.onTap,
    required this.width,
    required this.selectedColor,
    required this.unselectedColor,
  });

  final SaCardSelectorItem<T> item;
  final bool isSelected;
  final VoidCallback onTap;
  final double width;
  final Color selectedColor;
  final Color unselectedColor;

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: width,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.m),
          child: TweenAnimationBuilder(
            duration: Duration(milliseconds: isSelected ? 300 : 150),
            curve: isSelected ? const Interval(0.5, 1, curve: Curves.easeOutCubic) : Curves.easeIn,
            tween: Tween<double>(
              begin: isSelected ? 1.0 : 0.0,
              end: isSelected ? 1.0 : 0.0,
            ),
            builder: (_, progress, child) {
              final currentColor = Color.lerp(unselectedColor, selectedColor, progress)!;

              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                spacing: AppSpacing.s,
                children: [
                  SaDecoratedIcon(
                    icon: item.icon,
                    iconColor: currentColor,
                    backgroundColor: progress > 0.5 ? null : Colors.transparent,
                    shape: BoxShape.circle,
                  ),
                  SaText(
                    item.label,
                    style: AppTextStyle.body.copyWith(color: currentColor),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
