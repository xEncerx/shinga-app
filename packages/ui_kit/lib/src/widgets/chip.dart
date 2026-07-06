import 'package:flutter/material.dart';
import 'package:ui_kit/ui_kit.dart';

/// A custom chip widget for displaying selectable items.
class SaChip extends StatelessWidget {
  /// Creates a [SaChip] widget.
  const SaChip({
    required this.label,
    super.key,
    this.onTap,
    this.color,
    this.elevation = 0,
    this.textStyle,
    this.textColor,
    this.icon,
    this.leadingIcon,
    this.iconColor,
  });

  /// The text to display inside the chip.
  final String label;

  /// Called when the chip is tapped.
  final VoidCallback? onTap;

  /// Optional custom color for the chip.
  /// If not provided, will use the theme's primary color.
  final Color? color;

  /// The elevation of the chip, which controls the shadow depth.
  final double elevation;

  /// Optional custom text style for the chip label.
  final TextStyle? textStyle;

  /// Optional custom text color for the chip label.
  final Color? textColor;

  /// Optional trailing icon to display in the chip.
  final SaIconSource? icon;

  /// Optional leading icon to display in the chip.
  final SaIconSource? leadingIcon;

  /// Optional custom color for the chip's icon.
  final Color? iconColor;

  @override
  Widget build(BuildContext context) {
    final chipTheme = ChipTheme.of(context);

    final chipColor = color ?? chipTheme.backgroundColor?.withValues(alpha: 0.05);
    final chipBorderColor = chipColor?.withValues(alpha: 0.3) ?? Colors.transparent;
    final foregroundColor = chipColor?.foreground(context);

    return Material(
      clipBehavior: Clip.antiAlias,
      shape: chipTheme.shape?.copyWith(
        side: BorderSide(color: chipBorderColor, width: 0.7),
      ),
      elevation: elevation,
      child: Ink(
        color: chipColor,
        child: InkWell(
          onTap: onTap,
          splashFactory: NoSplash.splashFactory,
          highlightColor: chipColor?.highlightColor(),
          hoverColor: chipColor?.hoverColor(),
          mouseCursor: onTap != null ? SystemMouseCursors.click : SystemMouseCursors.basic,
          child: Padding(
            padding:
                chipTheme.padding ??
                const EdgeInsets.symmetric(
                  horizontal: AppSpacing.m,
                  vertical: AppSpacing.s,
                ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (leadingIcon != null) ...[
                  SaIcon(
                    icon: leadingIcon!,
                    size: 16,
                    color: iconColor ?? foregroundColor,
                  ),
                  const SizedBox(width: AppSpacing.xs),
                ],
                SaText(
                  label,
                  style:
                      textStyle ??
                      AppTextStyle.chip.copyWith(
                        color: textColor ?? foregroundColor,
                      ),
                ),
                if (icon != null) ...[
                  const SizedBox(width: AppSpacing.xs),
                  SaIcon(
                    icon: icon!,
                    size: 16,
                    color: iconColor ?? foregroundColor,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// A collection of chips that handles spacing, wrapping, and expanding automatically.
class SaChipGroup extends StatefulWidget {
  /// Creates a group of custom chips with proper spacing and collapse/expand logic.
  const SaChipGroup({
    required this.chips,
    this.expandButtonLabel = 'more',
    this.collapseButtonLabel = 'Hide',
    super.key,
    this.spacing = AppSpacing.s,
    this.runSpacing = AppSpacing.s,
    this.animationDuration = const Duration(milliseconds: 300),
    this.maxVisibleChips,
    this.actionButtonStyle,
  });

  /// The list of chip widgets to display.
  final List<Widget> chips;

  /// The horizontal spacing between chips.
  final double spacing;

  /// The vertical spacing between rows of chips.
  final double runSpacing;

  /// Maximum number of chips to show when collapsed.
  ///
  /// If null, all chips are displayed without the expand/collapse button.
  final int? maxVisibleChips;

  /// The duration of the expand/collapse animation.
  final Duration animationDuration;

  /// Text label for the expand button (e.g., "Show all").
  final String expandButtonLabel;

  /// Text label for the collapse button (e.g., "Hide").
  final String collapseButtonLabel;

  /// Action button text style.
  final TextStyle? actionButtonStyle;

  @override
  State<SaChipGroup> createState() => _SaChipGroupState();
}

class _SaChipGroupState extends State<SaChipGroup> {
  bool _isExpanded = false;

  void _toggleExpanded() {
    setState(() {
      _isExpanded = !_isExpanded;
    });
  }

  @override
  Widget build(BuildContext context) {
    final hasLimit =
        widget.maxVisibleChips != null && widget.chips.length > widget.maxVisibleChips!;
    final visibleChips = (hasLimit && !_isExpanded)
        ? widget.chips.take(widget.maxVisibleChips!).toList()
        : widget.chips.toList();

    if (hasLimit) {
      final moreCount = widget.chips.length - widget.maxVisibleChips!;
      visibleChips.add(
        SaChip(
          label: _isExpanded
              ? widget.collapseButtonLabel
              : '${widget.expandButtonLabel} $moreCount',
          leadingIcon: _isExpanded
              ? const SaIconSource.material(Icons.expand_less)
              : const SaIconSource.material(Icons.more_horiz),
          onTap: _toggleExpanded,
        ),
      );
    }

    return AnimatedSize(
      duration: widget.animationDuration,
      curve: Curves.easeInOut,
      alignment: Alignment.topLeft,
      child: Wrap(
        spacing: widget.spacing,
        runSpacing: widget.runSpacing,
        children: visibleChips,
      ),
    );
  }
}
