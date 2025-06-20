import 'package:flutter/material.dart';

/// Extension methods to simplify working with [TextStyle] objects.
extension TextStyleExtensions on TextStyle? {
  // Sets the font weight of the text style.
  TextStyle? weight(FontWeight v) => this?.copyWith(fontWeight: v);

  // Weights
  TextStyle? get thin => weight(FontWeight.w100);
  TextStyle? get extraLight => weight(FontWeight.w200);
  TextStyle? get light => weight(FontWeight.w300);
  TextStyle? get regular => weight(FontWeight.normal);
  TextStyle? get medium => weight(FontWeight.w500);
  TextStyle? get semiBold => weight(FontWeight.w600);
  TextStyle? get bold => weight(FontWeight.w700);
  TextStyle? get extraBold => weight(FontWeight.w800);
  TextStyle? get black => weight(FontWeight.w900);

  // Shortcut for color
  TextStyle? textColor(Color v) => this?.copyWith(color: v);

  // Shortcut for height
  TextStyle? height(double v) => this?.copyWith(height: v);

  // Shortcut for ellipsis overflow
  TextStyle? get ellipsis => this?.copyWith(overflow: TextOverflow.ellipsis);
}
