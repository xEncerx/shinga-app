import 'package:flutter/material.dart';

extension ClickableExtension on Widget {
  /// Makes the widget clickable by changing the mouse cursor to a pointer.
  Widget get clickable {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: this,
    );
  }
}
