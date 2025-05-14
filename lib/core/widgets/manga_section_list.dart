import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../cubit/cubit.dart';
import '../../data/data.dart';
import '../core.dart';

class MangaSectionList extends StatelessWidget {
  const MangaSectionList({
    super.key,
    required this.mangaListData,
    this.useCoverCache = true,
    this.isLoadingMore = false,
  });

  final List<Manga?> mangaListData;
  final bool useCoverCache;
  final bool isLoadingMore;

  @override
  Widget build(BuildContext context) {
    if (mangaListData.isEmpty) {
      // TODO: pretty not found page
      return Center(
        child: Text(
          "No manga found",
          style: Theme.of(context).textTheme.headlineMedium,
        ),
      );
    }

    return ScrollConfiguration(
      behavior: ScrollConfiguration.of(context).copyWith(
        dragDevices: {
          PointerDeviceKind.touch,
          PointerDeviceKind.mouse,
        },
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 5),
        child: BlocSelector<AppSettingsCubit, AppSettingsState, bool>(
          selector: (state) => state.appSettings.isCardButtonStyle,
          builder: (context, isCardButtonStyle) {
            return isCardButtonStyle
                ? _CardMangaList(
                    mangaListData: mangaListData,
                    useCoverCache: useCoverCache,
                  )
                : _TileMangaList(
                    mangaListData: mangaListData,
                    useCoverCache: useCoverCache,
                  );
          },
        ),
      ),
    );
  }
}

class _CardMangaList extends StatelessWidget {
  const _CardMangaList({
    required this.mangaListData,
    required this.useCoverCache,
  });

  final List<Manga?> mangaListData;
  final bool useCoverCache;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      itemCount: mangaListData.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 8.0,
        mainAxisSpacing: 8.0,
        childAspectRatio: 0.62,
      ),
      itemBuilder: (context, index) => CardMangaButton(
        mangaData: mangaListData[index]!,
        useCoverCache: useCoverCache,
      ),
    );
  }
}

class _TileMangaList extends StatelessWidget {
  const _TileMangaList({
    required this.mangaListData,
    required this.useCoverCache,
  });

  final List<Manga?> mangaListData;
  final bool useCoverCache;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      itemCount: mangaListData.length,
      separatorBuilder: (context, index) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        return TileMangaButton(
          mangaData: mangaListData[index]!,
          useCoverCache: useCoverCache,
        );
      },
    );
  }
}
