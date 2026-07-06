import 'package:ui_kit/src/src.dart';

/// An item in a card selector widget.
class SaCardSelectorItem<T> {
  /// Creates a [SaCardSelectorItem] instance.
  const SaCardSelectorItem({
    required this.value,
    required this.icon,
    required this.label,
  });

  /// The value associated with this item.
  final T value;

  /// The icon to display for this item.
  final SaIconSource icon;

  /// The label text for this item.
  final String label;
}
