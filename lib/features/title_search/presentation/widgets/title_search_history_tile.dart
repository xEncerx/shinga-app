import 'package:flutter/material.dart';
import 'package:ui_kit/ui_kit.dart';

/// A tile widget displaying a single search history item.
class TitleSearchHistoryTile extends StatelessWidget {
  /// Creates a [TitleSearchHistoryTile] widget.
  const TitleSearchHistoryTile({
    required this.title,
    required this.onTap,
    required this.onDelete,
    super.key,
  });

  /// The search query text.
  final String title;

  /// Callback invoked when the tile is tapped.
  final VoidCallback onTap;

  /// Callback invoked when the delete button is tapped.
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return SaListTile(
      tileColor: Colors.transparent,
      leading: const SaIcon(icon: SaIconSource.huge(HugeIconsStrokeRounded.clock01)),
      title: SaText(
        title,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        style: AppTextStyle.titleS,
      ),
      trailing: SaIconButton(
        icon: const SaIcon(icon: SaIconSource.huge(HugeIconsStrokeRounded.delete02)),
        onPressed: onDelete,
      ),
      onTap: onTap,
    );
  }
}
