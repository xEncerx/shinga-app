import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

import '../../../core/core.dart';
import '../../../data/data.dart';
import '../../../i18n/strings.g.dart';
import '../../features.dart';

/// Screen displaying the user's favorite title's.
@RoutePage()
class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({
    super.key,
    this.initial = BookMarkType.reading,
  });

  final BookMarkType initial;

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: BookMarkType.aValues.length,
      // * Skip 'notReading' bookmark
      initialIndex: widget.initial.index - 1,
      vsync: this,
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(FavoritesScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    _tabController.index = widget.initial.index - 1;
  }

  @override
  Widget build(BuildContext context) {
    final t = Translations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: ListTile(
          onTap: () => context.router.pushPath('/search'),
          tileColor: Theme.of(context).colorScheme.secondaryContainer,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          leading: const Icon(Icons.search_rounded),
          title: Text(
            t.searching.buttonText,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        actionsPadding: const EdgeInsets.only(right: 15),
        actions: [
          IconButton(
            onPressed: () => _openFilterBottomSheet(context),
            icon: const Icon(Icons.filter_alt),
          ),
        ],
        bottom: TabBar(
          isScrollable: true,
          controller: _tabController,
          tabs: BookMarkType.aValues.map((bookmark) {
            return Tab(text: bookmark.i18n);
          }).toList(),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(5),
          child: TabBarView(
            controller: _tabController,
            children: BookMarkType.aValues
                .map((bookmark) => FavoriteTabView(bookmark: bookmark))
                .toList(),
          ),
        ),
      ),
    );
  }

  Future<void> _openFilterBottomSheet(BuildContext context) async {
    final favoritesBloc = context.read<FavoritesBloc>();
    final filterData = favoritesBloc.filterData;

    final result = await showMaterialModalBottomSheet<TitlesFilterFields>(
      context: context,
      builder: (context) {
        return TitlesFilterBottomSheet(
          initialFilter: filterData,
          disableBookmarks: true,
        );
      },
    );

    if (context.mounted && result != null) {
      context.read<FavoritesBloc>().add(ApplyFiltersToFavorites(result));
    }
  }
}
