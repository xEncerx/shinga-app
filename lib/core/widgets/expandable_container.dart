import 'package:flutter/material.dart';

import '../extensions/extensions.dart';
import 'animated_clip_rect.dart';
import 'icon_container.dart';

/// Widget that displays a collapsible section with a header and expandable content.
///
/// When tapped, the section expands or collapses to show/hide the content.
class ExpandableSection extends StatefulWidget {
  const ExpandableSection({
    super.key,
    required this.title,
    required this.icon,
    required this.content,
    this.trailing,
    this.initiallyExpanded = false,
    this.expandDuration = const Duration(milliseconds: 200),
    this.onExpansionChanged,
    this.backgroundColor,
    this.padding = const EdgeInsets.all(16),
    this.borderRadius = 12.0,
    this.backgroundOpacity = 0.1,
    this.iconBackgroundOpacity = 0.1,
    this.alignment = Alignment.topCenter,
  });

  /// The title text displayed in the header.
  final String title;

  /// The icon displayed in the header.
  final IconData icon;

  /// The content widget displayed when the section is expanded.
  final Widget content;

  /// Optional widget displayed to the right of the title (before the chevron).
  final Widget? trailing;

  /// Whether the section is initially expanded.
  final bool initiallyExpanded;

  /// The duration of the expand/collapse animation.
  final Duration expandDuration;

  /// Callback invoked when the expansion state changes.
  final ValueChanged<bool>? onExpansionChanged;

  /// Background color of the section. If null, uses theme's primary color with opacity.
  final Color? backgroundColor;

  /// Padding around the entire section.
  final EdgeInsets padding;

  /// Border radius of the section.
  final double borderRadius;

  /// Opacity of the background color (used when backgroundColor is null).
  final double backgroundOpacity;

  /// Opacity of the icon container background.
  final double iconBackgroundOpacity;

  /// Alignment for the expandable content animation.
  final Alignment alignment;

  @override
  State<ExpandableSection> createState() => _ExpandableSectionState();
}

class _ExpandableSectionState extends State<ExpandableSection> {
  late bool _isExpanded;

  @override
  void initState() {
    super.initState();
    _isExpanded = widget.initiallyExpanded;
  }

  void _toggleExpansion() {
    setState(() {
      _isExpanded = !_isExpanded;
    });
    widget.onExpansionChanged?.call(_isExpanded);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: widget.padding,
      decoration: BoxDecoration(
        color:
            widget.backgroundColor ??
            theme.colorScheme.primary.withValues(alpha: widget.backgroundOpacity),
        borderRadius: BorderRadius.circular(widget.borderRadius),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          GestureDetector(
            onTap: _toggleExpansion,
            child: Row(
              children: [
                IconContainer(
                  icon: widget.icon,
                  backgroundOpacity: widget.iconBackgroundOpacity,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    widget.title,
                    style: theme.textTheme.titleMedium.semiBold.withColor(
                      theme.colorScheme.onSurface,
                    ),
                  ),
                ),
                if (widget.trailing != null) ...[
                  widget.trailing!,
                  const SizedBox(width: 8),
                ],
                AnimatedRotation(
                  turns: _isExpanded ? 0.5 : 0,
                  duration: widget.expandDuration,
                  child: Icon(
                    Icons.keyboard_arrow_down,
                    color: theme.colorScheme.outline,
                  ),
                ),
              ],
            ),
          ).clickable,
          AnimatedClipRect(
            open: _isExpanded,
            alignment: Alignment.topCenter,
            duration: widget.expandDuration,
            child: Padding(
              padding: const EdgeInsets.only(top: 15),
              child: widget.content,
            ),
          ),
        ],
      ),
    );
  }
}
