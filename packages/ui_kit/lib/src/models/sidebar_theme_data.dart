import 'package:flutter/material.dart';

/// Defines the visual appearance of a sidebar widget.
///
/// Pass an instance of this class to your sidebar widget to control
/// its colors, sizes, decorations, and item-level theming. Fields that
/// are `null` fall back to the widget's defaults.
class SaSidebarThemeData {
  /// Creates a [SaSidebarThemeData] instance.
  const SaSidebarThemeData({
    this.width = 70,
    this.height = double.infinity,
    this.padding = EdgeInsets.zero,
    this.margin = EdgeInsets.zero,
    this.decoration,
    this.iconTheme,
    this.selectedIconTheme,
    this.hoverIconTheme,
    this.textStyle,
    this.selectedTextStyle,
    this.hoverTextStyle,
    this.itemDecoration,
    this.selectedItemDecoration,
    this.itemMargin,
    this.selectedItemMargin,
    this.itemPadding,
    this.selectedItemPadding,
    this.itemTextPadding,
    this.selectedItemTextPadding,
    this.hoverColor,
  });

  /// Width of the sidebar in logical pixels.
  final double width;

  /// Height of the sidebar in logical pixels.
  final double height;

  /// Inner padding of the sidebar container.
  final EdgeInsets padding;

  /// Outer margin of the sidebar container.
  final EdgeInsets margin;

  /// Decoration applied to the sidebar container.
  final BoxDecoration? decoration;

  /// Icon theme for unselected items.
  final IconThemeData? iconTheme;

  /// Icon theme for the currently selected item.
  final IconThemeData? selectedIconTheme;

  /// Icon theme applied when the cursor hovers over an item.
  final IconThemeData? hoverIconTheme;

  /// Text style for unselected item labels.
  final TextStyle? textStyle;

  /// Text style for the currently selected item label.
  final TextStyle? selectedTextStyle;

  /// Text style applied when the cursor hovers over an item label.
  final TextStyle? hoverTextStyle;

  /// Decoration applied to unselected item tiles.
  final BoxDecoration? itemDecoration;

  /// Decoration applied to the currently selected item tile.
  final BoxDecoration? selectedItemDecoration;

  /// Margin around unselected item tiles.
  final EdgeInsets? itemMargin;

  /// Margin around the currently selected item tile.
  final EdgeInsets? selectedItemMargin;

  /// Padding inside unselected item tiles.
  final EdgeInsets? itemPadding;

  /// Padding inside the currently selected item tile.
  final EdgeInsets? selectedItemPadding;

  /// Padding between an unselected item tile and its label.
  final EdgeInsets? itemTextPadding;

  /// Padding between the selected item tile and its label.
  final EdgeInsets? selectedItemTextPadding;

  /// Background color of an item tile when the cursor hovers over it.
  final Color? hoverColor;

  /// Returns a copy of this theme with the given fields replaced.
  ///
  /// Non-null arguments override the corresponding field; `null` arguments
  /// leave the current value unchanged.
  SaSidebarThemeData copyWith({
    double? width,
    double? height,
    EdgeInsets? padding,
    EdgeInsets? margin,
    BoxDecoration? decoration,
    IconThemeData? iconTheme,
    IconThemeData? selectedIconTheme,
    IconThemeData? hoverIconTheme,
    TextStyle? textStyle,
    TextStyle? selectedTextStyle,
    TextStyle? hoverTextStyle,
    BoxDecoration? itemDecoration,
    BoxDecoration? selectedItemDecoration,
    EdgeInsets? itemMargin,
    EdgeInsets? selectedItemMargin,
    EdgeInsets? itemPadding,
    EdgeInsets? selectedItemPadding,
    EdgeInsets? itemTextPadding,
    EdgeInsets? selectedItemTextPadding,
    Color? hoverColor,
  }) {
    return SaSidebarThemeData(
      width: width ?? this.width,
      height: height ?? this.height,
      padding: padding ?? this.padding,
      margin: margin ?? this.margin,
      decoration: decoration ?? this.decoration,
      iconTheme: iconTheme ?? this.iconTheme,
      selectedIconTheme: selectedIconTheme ?? this.selectedIconTheme,
      hoverIconTheme: hoverIconTheme ?? this.hoverIconTheme,
      textStyle: textStyle ?? this.textStyle,
      selectedTextStyle: selectedTextStyle ?? this.selectedTextStyle,
      hoverTextStyle: hoverTextStyle ?? this.hoverTextStyle,
      itemDecoration: itemDecoration ?? this.itemDecoration,
      selectedItemDecoration: selectedItemDecoration ?? this.selectedItemDecoration,
      itemMargin: itemMargin ?? this.itemMargin,
      selectedItemMargin: selectedItemMargin ?? this.selectedItemMargin,
      itemPadding: itemPadding ?? this.itemPadding,
      selectedItemPadding: selectedItemPadding ?? this.selectedItemPadding,
      itemTextPadding: itemTextPadding ?? this.itemTextPadding,
      selectedItemTextPadding: selectedItemTextPadding ?? this.selectedItemTextPadding,
      hoverColor: hoverColor ?? this.hoverColor,
    );
  }

  /// Merges this theme with [fallback], using [fallback] values only for
  /// fields that are not set in `this`.
  ///
  /// Typical usage — apply user theme on top of widget defaults:
  /// ```dart
  /// final resolved = (userTheme ?? const SaSidebarThemeData()).mergeWith(defaultTheme);
  /// ```
  SaSidebarThemeData mergeWith(SaSidebarThemeData fallback) {
    return SaSidebarThemeData(
      width: width,
      height: height,
      padding: padding,
      margin: margin,
      decoration: decoration ?? fallback.decoration,
      iconTheme: iconTheme ?? fallback.iconTheme,
      selectedIconTheme: selectedIconTheme ?? fallback.selectedIconTheme,
      hoverIconTheme: hoverIconTheme ?? fallback.hoverIconTheme,
      textStyle: textStyle ?? fallback.textStyle,
      selectedTextStyle: selectedTextStyle ?? fallback.selectedTextStyle,
      hoverTextStyle: hoverTextStyle ?? fallback.hoverTextStyle,
      itemDecoration: itemDecoration ?? fallback.itemDecoration,
      selectedItemDecoration: selectedItemDecoration ?? fallback.selectedItemDecoration,
      itemMargin: itemMargin ?? fallback.itemMargin,
      selectedItemMargin: selectedItemMargin ?? fallback.selectedItemMargin,
      itemPadding: itemPadding ?? fallback.itemPadding,
      selectedItemPadding: selectedItemPadding ?? fallback.selectedItemPadding,
      itemTextPadding: itemTextPadding ?? fallback.itemTextPadding,
      selectedItemTextPadding: selectedItemTextPadding ?? fallback.selectedItemTextPadding,
      hoverColor: hoverColor ?? fallback.hoverColor,
    );
  }
}
