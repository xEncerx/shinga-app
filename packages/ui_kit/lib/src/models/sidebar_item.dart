import 'package:ui_kit/ui_kit.dart';

/// A data model representing a single item in a [SaSideBar].
class SaSidebarItem {
  /// Creates a [SaSidebarItem] with the given [icon] and optional [label].
  const SaSidebarItem({
    required this.icon,
    this.label,
    this.isSelectable = true,
  });

  /// The optional label text displayed next to the icon when the sidebar is extended.
  final String? label;

  /// The icon source used to render the item's icon.
  final SaIconSource icon;

  /// Whether this item can be selected by the user.
  ///
  /// Defaults to `true`. Set to `false` for non-interactive items such as dividers or headers.
  final bool isSelectable;
}
