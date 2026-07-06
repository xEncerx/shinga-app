import 'package:flutter/material.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:shinga/domain/domain.dart';
import 'package:shinga/features/features.dart';
import 'package:shinga/i18n/strings.g.dart';
import 'package:ui_kit/ui_kit.dart';

/// A paginated list widget for displaying titles.
class TitlePagedList extends StatefulWidget {
  /// Creates a [TitlePagedList] widget.
  const TitlePagedList({
    required this.state,
    required this.onFetchPage,
    required this.onRefresh,
    this.useCoverCache = true,
    this.buttonStyle = TitleButtonStyle.card,
    super.key,
  });

  /// The paging state containing the current items.
  final PagingState<int, TitleWithUserDataEntity> state;

  /// Callback invoked to fetch the next page.
  final VoidCallback onFetchPage;

  /// Callback invoked to refresh the list.
  final VoidCallback onRefresh;

  /// Whether to cache cover images.
  final bool useCoverCache;

  /// The display style for title items.
  final TitleButtonStyle buttonStyle;

  @override
  State<TitlePagedList> createState() => _TitlePagedListState();
}

class _TitlePagedListState extends State<TitlePagedList> {
  final _scrollController = ScrollController();
  bool _isScrolledDown = false;

  // Threshold for showing/hiding FAB (in pixels)
  static const double _scrollThreshold = 200;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_onScroll)
      ..dispose();
    super.dispose();
  }

  void _onScroll() {
    final shouldShowFab = _scrollController.offset > _scrollThreshold;

    if (shouldShowFab != _isScrolledDown) {
      setState(() {
        _isScrolledDown = shouldShowFab;
      });
    }
  }

  Future<void> _scrollToTop() async {
    await _scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isCardStyle = widget.buttonStyle == TitleButtonStyle.card;

    return Scaffold(
      floatingActionButton: AnimatedScale(
        scale: _isScrolledDown ? 1.0 : 0.0,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutCubic,
        child: SaFloatingActionButton(
          onPressed: _scrollToTop,
          child: const SaIcon(
            icon: SaIconSource.material(Icons.keyboard_arrow_up_rounded),
            size: 28,
          ),
        ),
      ),
      body: PagedGridView(
        scrollController: _scrollController,
        state: widget.state,
        physics: const AlwaysScrollableScrollPhysics(),
        showNewPageProgressIndicatorAsGridChild: false,
        showNewPageErrorIndicatorAsGridChild: false,
        showNoMoreItemsIndicatorAsGridChild: false,
        fetchNextPage: widget.onFetchPage,
        gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: isCardStyle ? TitleCard.defaultWidth : TitleTile.maxWidth,
          mainAxisSpacing: AppSpacing.s,
          crossAxisSpacing: AppSpacing.s,
          childAspectRatio: isCardStyle ? TitleCard.defaultWidth / TitleCard.defaultHeight : 1,
          mainAxisExtent: !isCardStyle ? TitleTile.defaultHeight : null,
        ),
        builderDelegate: PagedChildBuilderDelegate<TitleWithUserDataEntity>(
          firstPageErrorIndicatorBuilder: _buildFirstPageError,
          noItemsFoundIndicatorBuilder: _buildNoItems,
          itemBuilder: (_, item, _) => isCardStyle
              ? TitleCard(
                  key: ValueKey(item.title.id),
                  entity: item,
                  useCoverCache: widget.useCoverCache,
                )
              : TitleTile(
                  key: ValueKey(item.title.id),
                  entity: item,
                  useCoverCache: widget.useCoverCache,
                ),
        ),
      ),
    );
  }

  Widget _buildFirstPageError(BuildContext context) {
    final t = Translations.of(context);

    return SaStateMessage.error(
      title: t.titles.errors.fetchError.title,
      description: t.titles.errors.fetchError.description,
      buttonText: t.common.retry,
      onPressed: widget.onRefresh,
    );
  }

  Widget _buildNoItems(BuildContext context) {
    final t = Translations.of(context);

    return SaStateMessage.empty(
      title: t.titles.errors.emptyList.title,
      description: t.titles.errors.emptyList.description,
    );
  }
}
