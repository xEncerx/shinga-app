import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shinga/domain/domain.dart';
import 'package:shinga/features/features.dart';
import 'package:shinga/i18n/i18n.dart';
import 'package:ui_kit/ui_kit.dart';

/// Displays bookmark action buttons in the title detail menu.
class TitleDetailBookmarkActions extends StatefulWidget {
  /// Creates a [TitleDetailBookmarkActions] widget.
  const TitleDetailBookmarkActions({super.key});

  @override
  State<TitleDetailBookmarkActions> createState() => _TitleDetailBookmarkActionsState();
}

class _TitleDetailBookmarkActionsState extends State<TitleDetailBookmarkActions>
    with SingleTickerProviderStateMixin {
  static const _itemHeight = 48.0;

  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 400),
  );

  @override
  void initState() {
    super.initState();
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const bookmarks = Bookmark.values;
    final height = bookmarks.length * _itemHeight + (bookmarks.length - 1) * AppSpacing.s;

    return BlocSelector<TitleDetailCubit, TitleDetailState, Bookmark?>(
      selector: (state) => state.data.userData?.bookmark,
      builder: (context, selectedBookmark) {
        return SizedBox(
          width: double.infinity,
          height: height,
          child: Flow(
            clipBehavior: Clip.none,
            delegate: _BookmarkActionsFlowDelegate(
              animation: _controller,
              itemHeight: _itemHeight,
            ),
            children: [
              for (final bookmark in bookmarks)
                TitleDetailBookmarkItem(
                  bookmark: bookmark,
                  isSelected: bookmark == selectedBookmark,
                  hasBookmark: selectedBookmark != null,
                ),
            ],
          ),
        );
      },
    );
  }
}

/// Positions bookmark actions vertically and animates them in sequence.
class _BookmarkActionsFlowDelegate extends FlowDelegate {
  _BookmarkActionsFlowDelegate({
    required this.animation,
    required this.itemHeight,
  }) : super(repaint: animation);

  final Animation<double> animation;
  final double itemHeight;

  @override
  BoxConstraints getConstraintsForChild(
    int index,
    BoxConstraints constraints,
  ) {
    return BoxConstraints(
      minHeight: itemHeight,
      maxHeight: itemHeight,
      maxWidth: constraints.maxWidth,
    );
  }

  @override
  void paintChildren(FlowPaintingContext context) {
    final childCount = context.childCount;
    if (childCount == 0) return;

    final step = childCount > 1 ? 0.5 / (childCount - 1) : 0.5;

    for (var index = 0; index < childCount; index++) {
      final childSize = context.getChildSize(index);
      if (childSize == null) continue;

      final reversedIndex = childCount - 1 - index;
      final start = reversedIndex * step;
      final end = start + 0.5;

      final progress = Curves.easeOutCubic.transform(
        Interval(start, end).transform(animation.value),
      );

      final y = index * (itemHeight + AppSpacing.s);
      final x = context.size.width - childSize.width;

      final slideX = childSize.width * 0.2 * (1 - progress);
      final slideY = itemHeight * 0.2 * (1 - progress);

      context.paintChild(
        index,
        opacity: progress,
        transform: Matrix4.translationValues(
          x + slideX,
          y + slideY,
          0,
        ),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _BookmarkActionsFlowDelegate oldDelegate) {
    return oldDelegate.itemHeight != itemHeight;
  }
}

/// A single bookmark action.
class TitleDetailBookmarkItem extends StatelessWidget {
  /// Creates a [TitleDetailBookmarkItem] widget.
  const TitleDetailBookmarkItem({
    required this.bookmark,
    required this.isSelected,
    required this.hasBookmark,
    super.key,
  });

  /// The bookmark represented by this action.
  final Bookmark bookmark;

  /// Whether this bookmark is currently selected.
  final bool isSelected;

  /// Whether the title is already present in the user's bookmarks.
  final bool hasBookmark;

  @override
  Widget build(BuildContext context) {
    final bookmarkColor = bookmark.highlightColor(context.appColors);
    final effectiveBgColor = bookmarkColor ?? context.colors.errorContainer;

    return Row(
      spacing: AppSpacing.m,
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        SaChip(
          label: bookmark.i18n,
          color: effectiveBgColor,
          leadingIcon: isSelected ? const SaIconSource.material(Icons.check_rounded) : null,
          textStyle: AppTextStyle.bodyBold.copyWith(
            color: effectiveBgColor.foreground(context),
          ),
        ),
        SaFloatingActionButton(
          size: 48,
          backgroundColor: effectiveBgColor,
          onPressed: isSelected ? () {} : () => _selectBookmark(context),
          child: SaIcon(icon: bookmark.icon),
        ),
      ],
    );
  }

  Future<void> _selectBookmark(BuildContext context) async {
    final cubit = context.read<TitleDetailCubit>();

    await context.router.maybePop();
    if (hasBookmark) {
      await cubit.changeBookmark(bookmark);
    } else {
      await cubit.addToBookmark(bookmark);
    }
  }
}
