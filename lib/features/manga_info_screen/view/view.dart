import 'dart:ui';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:group_button/group_button.dart';

import '../../../core/core.dart';
import '../../../data/data.dart';
import '../../../domain/domain.dart';
import '../../../i18n/strings.g.dart';
import '../../features.dart';

@RoutePage()
class MangaInfoScreen extends StatefulWidget {
  const MangaInfoScreen({
    super.key,
    required this.mangaData,
  });

  final Manga mangaData;

  @override
  State<MangaInfoScreen> createState() => _MangaInfoScreenState();
}

class _MangaInfoScreenState extends State<MangaInfoScreen> {
  final _urlController = TextEditingController();
  final _cubit = MangaInfoCubit();
  late GroupButtonController _radioController;
  late MangaSection _section;

  @override
  void initState() {
    _urlController.text = widget.mangaData.currentUrl ?? '';
    _section = widget.mangaData.section;
    _radioController = GroupButtonController(
      selectedIndex: MangaSection.selectableSections.indexOf(_section),
    );

    _cubit.loadMangaInfo(widget.mangaData);

    super.initState();
  }

  @override
  void dispose() {
    _urlController.dispose();
    _radioController.dispose();
    _cubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ScrollConfiguration(
        behavior: ScrollConfiguration.of(context).copyWith(
          dragDevices: {
            PointerDeviceKind.touch,
            PointerDeviceKind.mouse,
          },
        ),
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              expandedHeight: 400,
              pinned: true,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => context.router.pop(),
              ),
              flexibleSpace: FlexibleSpaceBar(
                background: _PreviewCover(widget.mangaData.cover),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: BlocConsumer<MangaInfoCubit, MangaInfoState>(
                  bloc: _cubit,
                  listener: (context, state) {
                    final String message;
                    if (state is MangaInfoSectionUpdated) {
                      message = t.titleInfo.sectionUpdated(
                        section: state.newSection.name,
                      );
                      context.read<FavoriteBloc>().add(RefreshAllSections());
                      context.read<SearchingBloc>().add(RefreshSearchingResult());
                    } else if (state is MangaInfoUrlUpdated) {
                      message = t.titleInfo.urlUpdated;
                      context.read<FavoriteBloc>().add(RefreshAllSections());
                      context.read<SearchingBloc>().add(RefreshSearchingResult());
                    } else if (state is MangaInfoError) {
                      message = state.error;
                    } else {
                      return;
                    }

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(message),
                      ),
                    );
                  },
                  buildWhen: (previous, current) {
                    return current is MangaInfoLoading && current.isMangaData ||
                        current is MangaInfoLoaded;
                  },
                  builder: (context, state) {
                    final bool isLoading = state is MangaInfoLoading && state.isMangaData;
                    final mangaData = state is MangaInfoLoaded ? state.manga : widget.mangaData;

                    return MangaContentBody(
                      mangaData: mangaData,
                      isLoading: isLoading,
                      cubit: _cubit,
                      urlController: _urlController,
                      radioController: _radioController,
                    );
                  },
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}

class _PreviewCover extends StatelessWidget {
  const _PreviewCover(this.coverUrl);

  final String coverUrl;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Stack(
        alignment: Alignment.center,
        children: [
          Opacity(
            opacity: 0.1,
            child: MangaPreviewCover(
              width: double.infinity,
              coverUrl: coverUrl,
            ),
          ),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  theme.scaffoldBackgroundColor,
                  theme.scaffoldBackgroundColor.withValues(alpha: 0.2),
                  theme.scaffoldBackgroundColor,
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: MangaPreviewCover(
              width: 250,
              height: 360,
              coverUrl: coverUrl,
            ),
          ),
        ],
      ),
    );
  }
}
