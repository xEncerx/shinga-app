import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:sidebarx/sidebarx.dart';
import 'package:ui_kit/ui_kit.dart';

/// A sidebar navigation widget that supports both collapsed and extended states.
///
/// Wraps the `SidebarX` package with custom theming via [SaSidebarThemeData]
/// and exposes a simplified API for managing the selected index and items.
class SaSideBar extends StatefulWidget {
  /// Creates a [SaSideBar] with the given list of [items].
  const SaSideBar({
    required this.items,
    super.key,
    this.theme,
    this.extendedTheme,
    this.extended = false,
    this.currentIndex,
    this.onTap,
  });

  /// The list of items to display in the sidebar.
  final List<SaSidebarItem> items;

  /// Whether the sidebar is in its extended state.
  ///
  /// Defaults to `false`.
  final bool extended;

  /// The theme applied when the sidebar is collapsed.
  ///
  /// Falls back to a default theme if not provided.
  final SaSidebarThemeData? theme;

  /// The theme applied when the sidebar is in its extended state.
  ///
  /// Falls back to a default extended theme if not provided.
  final SaSidebarThemeData? extendedTheme;

  /// The index of the currently selected item.
  ///
  /// When changed externally, the sidebar animates to the new selection.
  final int? currentIndex;

  /// Called when the user taps a sidebar item.
  ///
  /// Receives the index of the tapped item.
  final ValueChanged<int>? onTap;

  @override
  State<SaSideBar> createState() => _SaSideBarState();
}

class _SaSideBarState extends State<SaSideBar> {
  late final SidebarXController _controller;

  @override
  void initState() {
    _controller = SidebarXController(
      selectedIndex: widget.currentIndex ?? 0,
      extended: widget.extended,
    );
    super.initState();
  }

  @override
  void didUpdateWidget(SaSideBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.extended != widget.extended) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _controller.setExtended(widget.extended);
      });
    }
    if (oldWidget.currentIndex != widget.currentIndex && widget.currentIndex != null) {
      _controller.selectIndex(widget.currentIndex!);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final barTheme = BottomNavigationBarTheme.of(context);
    final colorScheme = context.colors;

    final defaultTheme = SaSidebarThemeData(
      margin: const EdgeInsets.all(AppSpacing.s),
      decoration: BoxDecoration(
        color: barTheme.backgroundColor,
        borderRadius: BorderRadius.circular(AppRadius.xxl),
      ),
      iconTheme: IconThemeData(color: barTheme.unselectedIconTheme?.color, size: 28),
      selectedIconTheme: IconThemeData(color: barTheme.selectedIconTheme?.color),
      hoverIconTheme: IconThemeData(color: colorScheme.onSurfaceVariant),
      itemTextPadding: const EdgeInsets.only(left: AppSpacing.m),
      textStyle: AppTextStyle.bodyL.copyWith(
        color: barTheme.unselectedLabelStyle?.color,
      ),
      selectedTextStyle: AppTextStyle.bodyL.copyWith(
        color: barTheme.selectedLabelStyle?.color,
      ),
      hoverTextStyle: AppTextStyle.bodyL.copyWith(
        color: colorScheme.onSurfaceVariant,
      ),
    );
    final defaultExtendedTheme = defaultTheme.copyWith(
      width: 200,
      margin: EdgeInsets.zero,
      decoration: BoxDecoration(
        color: barTheme.backgroundColor,
        borderRadius: const BorderRadius.only(
          topRight: Radius.circular(AppRadius.xxl),
          bottomRight: Radius.circular(AppRadius.xxl),
        ),
      ),
      selectedItemTextPadding: const EdgeInsets.only(left: AppSpacing.m),
    );

    final mergedTheme = (widget.theme ?? defaultTheme).mergeWith(defaultTheme);
    final mergedExtendedTheme = (widget.extendedTheme ?? defaultExtendedTheme).mergeWith(
      defaultExtendedTheme,
    );

    return SidebarX(
      controller: _controller,
      showToggleButton: false,
      items: widget.items
          .mapIndexed(
            (index, item) => SidebarXItem(
              // If widget.extended = false, we forcibly change the label to spaces so that the icons are centered.
              // The problem is in the implementation of SidebarX, and to avoid changing the library code, we had to go for such a crutch.
              label: widget.extended ? item.label : '   ',
              onTap: () => widget.onTap?.call(index),
              iconBuilder: (selected, hovered) => SaIcon(
                icon: item.icon,
                color: selected
                    ? mergedTheme.selectedIconTheme?.color
                    : hovered
                    ? mergedTheme.hoverIconTheme?.color
                    : mergedTheme.iconTheme?.color,
                size: mergedTheme.iconTheme?.size,
              ),
              selectable: item.isSelectable,
            ),
          )
          .toList(),
      theme: SidebarXTheme(
        width: mergedTheme.width,
        height: mergedTheme.height,
        padding: mergedTheme.padding,
        margin: mergedTheme.margin,
        decoration: mergedTheme.decoration,
        textStyle: mergedTheme.textStyle,
        selectedTextStyle: mergedTheme.selectedTextStyle,
        itemDecoration: mergedTheme.itemDecoration,
        selectedItemDecoration: mergedTheme.selectedItemDecoration,
        itemMargin: mergedTheme.itemMargin,
        selectedItemMargin: mergedTheme.selectedItemMargin,
        itemPadding: mergedTheme.itemPadding,
        selectedItemPadding: mergedTheme.selectedItemPadding,
        itemTextPadding: mergedTheme.itemTextPadding,
        selectedItemTextPadding: mergedTheme.selectedItemTextPadding,
        hoverColor: mergedTheme.hoverColor,
        hoverTextStyle: mergedTheme.hoverTextStyle,
        hoverIconTheme: mergedTheme.hoverIconTheme,
      ),
      extendedTheme: SidebarXTheme(
        width: mergedExtendedTheme.width,
        height: mergedExtendedTheme.height,
        padding: mergedExtendedTheme.padding,
        margin: mergedExtendedTheme.margin,
        decoration: mergedExtendedTheme.decoration,
        textStyle: mergedExtendedTheme.textStyle,
        selectedTextStyle: mergedExtendedTheme.selectedTextStyle,
        itemDecoration: mergedExtendedTheme.itemDecoration,
        selectedItemDecoration: mergedExtendedTheme.selectedItemDecoration,
        itemMargin: mergedExtendedTheme.itemMargin,
        selectedItemMargin: mergedExtendedTheme.selectedItemMargin,
        itemPadding: mergedExtendedTheme.itemPadding,
        selectedItemPadding: mergedExtendedTheme.selectedItemPadding,
        itemTextPadding: mergedExtendedTheme.itemTextPadding,
        selectedItemTextPadding: mergedExtendedTheme.selectedItemTextPadding,
        hoverColor: mergedExtendedTheme.hoverColor,
        hoverTextStyle: mergedExtendedTheme.hoverTextStyle,
        hoverIconTheme: mergedExtendedTheme.hoverIconTheme,
      ),
    );
  }
}
