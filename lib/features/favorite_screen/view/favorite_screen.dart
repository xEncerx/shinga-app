import 'package:auto_route/auto_route.dart';
import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

import '../../../core/widgets/widgets.dart';
import '../../../domain/domain.dart';
import '../../features.dart';

@RoutePage()
class FavoriteScreen extends StatefulWidget {
  const FavoriteScreen({super.key});

  @override
  State<FavoriteScreen> createState() => _FavoriteScreenState();
}

class _FavoriteScreenState extends State<FavoriteScreen> {
  static const _pageSize = 100;

  @override
  void initState() {
    context.read<FavoriteBloc>().add(
          LoadInitialUserManga(pageSize: _pageSize),
        );

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const FavoriteScreenAppBar(),
      body: BlocBuilder<FavoriteBloc, FavoriteState>(
        builder: (context, state) {
          // ! Display error message (favorite screen)
          if (state is FavoriteError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Error loading favorites',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(state.message),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      context.read<FavoriteBloc>().add(
                        LoadInitialUserManga(pageSize: _pageSize),
                      );
                    },
                    child: const Text('Try Again'),
                  ),
                ],
              ),
            );
          }
          
          if (state is FavoriteLoaded) {
            return DefaultTabController(
              // 3 section of manga: completed, reading, onFuture
              length: 3,
              initialIndex: 1, // reading section
              child: Column(
                spacing: 10,
                children: [
                  TabBar(
                    isScrollable: true,
                    tabs: [
                      Tab(
                        text: MangaSection.completed.name.capitalize,
                      ),
                      Tab(
                        text: MangaSection.reading.name.capitalize,
                      ),
                      Tab(
                        text: MangaSection.onFuture.name.capitalize,
                      )
                    ],
                  ),
                  Expanded(
                    child: TabBarView(
                      children: [
                        MangaSectionList(
                          mangaListData: state.completedMangaList,
                        ),
                        MangaSectionList(
                          mangaListData: state.readingMangaList,
                        ),
                        MangaSectionList(
                          mangaListData: state.onFutureMangaList,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }
          return Center(
            child: LoadingAnimationWidget.threeArchedCircle(
              color: Theme.of(context).colorScheme.primary,
              size: 50,
            ),
          );
        },
      ),
    );
  }
}
