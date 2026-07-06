import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shinga/domain/domain.dart';
import 'package:shinga/features/features.dart';
import 'package:shinga/i18n/i18n.dart';
import 'package:ui_kit/ui_kit.dart';

/// Displays bookmark action buttons in the title detail menu, allowing users to add or change the bookmark status of a title.
class TitleDetailBookmarkActions extends StatefulWidget {
  /// Creates a [TitleDetailBookmarkActions] widget.
  const TitleDetailBookmarkActions({super.key});

  @override
  State<TitleDetailBookmarkActions> createState() => _TitleDetailBookmarkActionsState();
}

class _TitleDetailBookmarkActionsState extends State<TitleDetailBookmarkActions>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 400),
  );

  @override
  void initState() {
    unawaited(_controller.forward());
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final length = Bookmark.values.length;
    final step = length > 1 ? 0.5 / (length - 1) : 0.5;

    return Column(
      spacing: AppSpacing.s,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: List.generate(length, (index) {
        final reversedIndex = length - 1 - index;
        final start = reversedIndex * step;
        final end = start + 0.5;
        final animation = CurvedAnimation(
          parent: _controller,
          curve: Interval(start, end, curve: Curves.easeOutCubic),
        );

        return FadeTransition(
          opacity: animation,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0.2, 0.2),
              end: Offset.zero,
            ).animate(animation),
            child: TitleDetailBookmarkItem(bookmark: Bookmark.values[index]),
          ),
        );
      }),
    );
  }
}

/// A widget that represents a single bookmark action item, allowing users to add or change the bookmark status of a title.
class TitleDetailBookmarkItem extends StatelessWidget {
  /// Creates a [TitleDetailBookmarkItem] widget.
  const TitleDetailBookmarkItem({required this.bookmark, super.key});

  /// The bookmark status represented by this item.
  final Bookmark bookmark;

  @override
  Widget build(BuildContext context) {
    final bookmarkColor = bookmark.highlightColor(context.appColors);
    final effectiveBgColor = bookmarkColor ?? context.colors.errorContainer;

    return BlocSelector<TitleDetailCubit, TitleDetailState, Bookmark?>(
      selector: (state) => state.data.userData?.bookmark,
      builder: (_, userBookmark) => Row(
        spacing: AppSpacing.m,
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          SaChip(
            label: bookmark.i18n,
            color: effectiveBgColor,
            leadingIcon: userBookmark == bookmark
                ? const SaIconSource.material(Icons.check_rounded)
                : null,
            textStyle: AppTextStyle.bodyBold.copyWith(color: effectiveBgColor.foreground(context)),
          ),
          SaFloatingActionButton(
            size: 48,
            backgroundColor: effectiveBgColor,
            onPressed: () async {
              context.router.pop();
              // If the user doesn't have a bookmark, add the title to their list with the selected bookmark status.
              if (userBookmark == null) {
                await context.read<TitleDetailCubit>().addToBookmark(bookmark);
                // If the title is already in the user's list, then we update its bookmark status to the selected one.
              } else {
                await context.read<TitleDetailCubit>().changeBookmark(bookmark);
              }
            },
            child: SaIcon(icon: bookmark.icon),
          ),
        ],
      ),
    );
  }
}
