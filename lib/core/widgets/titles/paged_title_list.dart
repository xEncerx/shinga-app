import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

import '../../../data/data.dart';
import '../../../features/features.dart';
import '../../../i18n/strings.g.dart';
import '../../core.dart';

/// A widget that displays a paginated list of titles with user data.
class PagedTitleList extends StatefulWidget {
  /// Creates a [PagedTitleList].
  ///
  /// - `state`: The current paging state containing the titles.
  /// - `onRefresh`: Callback to refresh the list.
  /// - `onFetchPage`: Callback to fetch the next page of titles.
  /// - `useCoverCache`: Whether to use cached covers for titles.
  const PagedTitleList({
    super.key,
    required this.state,
    required this.onRefresh,
    required this.onFetchPage,
    this.useCoverCache = true,
  });

  final PagingState<int, TitleWithUserData> state;
  final VoidCallback onRefresh;
  final VoidCallback onFetchPage;
  final bool useCoverCache;

  @override
  State<PagedTitleList> createState() => _PagedTitleListState();
}

class _PagedTitleListState extends State<PagedTitleList> {
  final _scrollController = ScrollController();
  bool _isScrolledDown = false;

  // Threshold for showing/hiding FAB (in pixels)
  static const double _scrollThreshold = 200.0;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    final bool shouldShowFab = _scrollController.offset > _scrollThreshold;

    if (shouldShowFab != _isScrolledDown) {
      setState(() {
        _isScrolledDown = shouldShowFab;
      });
    }
  }

  void _scrollToTop() {
    _scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocSelector<SettingsCubit, SettingsState, bool>(
      selector: (state) => state.settings.isCardButtonStyle,
      builder: (context, isCardStyle) {
        final builderDelegate = _createBuilderDelegate(
          context,
          isCardStyle,
        );

        return Scaffold(
          body: isCardStyle
              ? PagedGridView(
                  scrollController: _scrollController,
                  state: widget.state,
                  showNewPageProgressIndicatorAsGridChild: false,
                  showNewPageErrorIndicatorAsGridChild: false,
                  showNoMoreItemsIndicatorAsGridChild: false,
                  fetchNextPage: widget.onFetchPage,
                  builderDelegate: builderDelegate,
                  gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: TitleCard.width,
                    mainAxisSpacing: 8,
                    crossAxisSpacing: 8,
                    childAspectRatio: TitleCard.width / TitleCard.height,
                  ),
                )
              : PagedListView.separated(
                  scrollController: _scrollController,
                  state: widget.state,
                  fetchNextPage: widget.onFetchPage,
                  separatorBuilder: (_, _) => const SizedBox(height: 5),
                  builderDelegate: builderDelegate,
                ),
          floatingActionButton: _isScrolledDown
              ? FloatingActionButton(
                  key: const ValueKey('fab'),
                  onPressed: _scrollToTop,
                  child: const Icon(
                    Icons.keyboard_arrow_up_rounded,
                    size: 28,
                  ),
                )
              : const SizedBox.shrink(),
        );
      },
    );
  }

  /// Create the builder delegate for the PagedListView or PagedGridView
  PagedChildBuilderDelegate<TitleWithUserData> _createBuilderDelegate(
    BuildContext context,
    bool isCardStyle,
  ) {
    return PagedChildBuilderDelegate<TitleWithUserData>(
      itemBuilder: (context, item, index) {
        return isCardStyle
            ? TitleCard(
                titleData: item,
                useCoverCache: widget.useCoverCache,
              )
            : TitleTile(
                titleData: item,
                useCoverCache: widget.useCoverCache,
              );
      },
      firstPageProgressIndicatorBuilder: _buildFirstPageProgress,
      newPageProgressIndicatorBuilder: _buildNewPageProgress,
      firstPageErrorIndicatorBuilder: _buildFirstPageError,
      noItemsFoundIndicatorBuilder: _buildNoItemsFound,
    );
  }

  /// First page progress indicator
  Widget _buildFirstPageProgress(BuildContext context) {
    return Center(
      child: LoadingAnimationWidget.threeArchedCircle(
        color: Theme.of(context).colorScheme.primary,
        size: 50,
      ),
    );
  }

  /// New page progress indicator
  Widget _buildNewPageProgress(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 16, bottom: 16),
      child: Center(
        child: LoadingAnimationWidget.horizontalRotatingDots(
          color: Theme.of(context).colorScheme.primary,
          size: 40,
        ),
      ),
    );
  }

  /// First page error indicator
  Widget _buildFirstPageError(BuildContext context) {
    return ShowInfoWidget.error(
      title: t.errors.somethingWentWrong,
      description: t.errors.unknownError,
      onRetry: widget.onRefresh,
    );
  }

  /// No items found indicator
  Widget _buildNoItemsFound(BuildContext context) {
    return ShowInfoWidget.warning(
      title: t.errors.notFound,
      description: t.errors.emptyList,
    );
  }
}
