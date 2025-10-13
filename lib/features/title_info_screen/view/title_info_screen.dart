import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/core.dart';
import '../../../data/data.dart';
import '../../../i18n/strings.g.dart';
import '../../../utils/utils.dart';
import '../../features.dart';

@RoutePage()
class TitleInfoScreen extends StatefulWidget {
  const TitleInfoScreen({
    super.key,
    required this.titleData,
  });

  final TitleWithUserData titleData;

  @override
  State<TitleInfoScreen> createState() => _TitleInfoScreenState();
}

class _TitleInfoScreenState extends State<TitleInfoScreen> {
  final _urlController = TextEditingController();
  final _scrollController = ScrollController();
  bool _isCollapsed = false;

  // Heights for the SliverAppBar
  static const double _expandedHeight = 400.0;
  static const double _collapsedHeight = kToolbarHeight;

  @override
  void initState() {
    super.initState();
    _urlController.text = widget.titleData.userData?.currentUrl ?? '';
    _scrollController.addListener(_onScroll);
  }

  /// Handle scroll events to update the collapsed state
  void _onScroll() {
    final isCollapsed =
        _scrollController.hasClients &&
        _scrollController.offset > (_expandedHeight - _collapsedHeight);

    if (_isCollapsed != isCollapsed) {
      setState(() => _isCollapsed = isCollapsed);
    }
  }

  @override
  void dispose() {
    _urlController.dispose();
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  /// Get the display name based on the app's language setting
  String get _displayName {
    final appSettings = context.read<SettingsCubit>().settings;
    final title = widget.titleData.title;

    return appSettings.language == AppLocale.ru ? title.nameRu ?? '???' : title.nameEn ?? '???';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocProvider(
      create: (context) => TitleInfoBloc(getIt<RestClient>()),
      child: BlocListener<TitleInfoBloc, TitleInfoState>(
        listener: (context, state) {
          if (state is TitleInfoLoaded) {
            showSnackBar(context, t.titleInfo.success.titleUpdated);
          }
        },
        child: Scaffold(
          body: SafeArea(
            child: CustomScrollView(
              controller: _scrollController,
              slivers: [
                SliverAppBar(
                  expandedHeight: _expandedHeight,
                  collapsedHeight: _collapsedHeight,
                  pinned: true,
                  leading: IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () => context.router.pop(),
                  ),
                  title: AnimatedOpacity(
                    duration: const Duration(milliseconds: 200),
                    opacity: _isCollapsed ? 1.0 : 0.0,
                    child: Text(
                      _displayName,
                      maxLines: 2,
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleMedium,
                    ),
                  ),
                  centerTitle: true,
                  // Empty widget to balance the leading icon
                  actions: const [SizedBox(width: 54)],
                  flexibleSpace: FlexibleSpaceBar(
                    background: TitleInfoPreviewCover(
                      coverUrl: widget.titleData.title.cover.largeUrl?.fullUrl ?? '',
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: TitleInfoContentBody(
                      titleData: widget.titleData,
                      urlController: _urlController,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
