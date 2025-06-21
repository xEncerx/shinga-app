import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:group_button/group_button.dart';

import '../../../core/core.dart';
import '../../../i18n/strings.g.dart';
import '../bloc/favorite_bloc.dart';

class FavoriteSortingDrawer extends StatefulWidget {
  const FavoriteSortingDrawer({super.key});

  @override
  State<FavoriteSortingDrawer> createState() => _FavoriteSortingDrawerState();
}

class _FavoriteSortingDrawerState extends State<FavoriteSortingDrawer> {
  late final GroupButtonController sortByController;
  late final GroupButtonController sortOrderController;
  final nameSortingController = TextEditingController();
  bool isNameSortingActive = false;
  Timer? _debounceTimer;

  @override
  void initState() {
    final bloc = context.read<FavoriteBloc>();

    sortByController = GroupButtonController(
      selectedIndex: bloc.sortingMethod.index,
    );
    sortOrderController = GroupButtonController(
      selectedIndex: bloc.sortingOrder.index,
    );
    isNameSortingActive = bloc.sortingMethod == SortingEnum.name;
    nameSortingController.text = bloc.nameFilter;
    nameSortingController.addListener(_onNameFilterChanged);

    super.initState();
  }

  @override
  void dispose() {
    sortByController.dispose();
    sortOrderController.dispose();
    nameSortingController.removeListener(_onNameFilterChanged);
    nameSortingController.dispose();
    _debounceTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Drawer(
      backgroundColor: theme.scaffoldBackgroundColor,
      child: ListView(
        padding: const EdgeInsets.all(10),
        children: [
          Center(
            child: Text(
              t.sorting.title,
              style: theme.textTheme.headlineSmall,
            ),
          ),
          const SizedBox(height: 10),
          if (isNameSortingActive) ...[
            StyledTextField(
              controller: nameSortingController,
              hintText: t.sorting.byName,
              bgColor: theme.colorScheme.secondary,
              leftContentPadding: 20,
              rightContentPadding: 20,
            ),
          ],
          GroupButton<SortingEnum>(
            controller: sortByController,
            buttons: SortingEnum.values,
            options: const GroupButtonOptions(runSpacing: 0),
            buttonIndexedBuilder: (selected, index, context) {
              final sortingType = SortingEnum.values[index];

              if (sortingType == SortingEnum.name && isNameSortingActive) {
                return const SizedBox.shrink();
              }

              return RadioTile(
                title: SortingEnum.values[index].getLocalizedName(),
                selected: sortByController.selectedIndex,
                index: index,
                onTap: () {
                  setState(() {
                    if (sortingType == SortingEnum.name) {
                      isNameSortingActive = true;
                    } else {
                      isNameSortingActive = false;
                      nameSortingController.clear();
                    }
                  });

                  context.read<FavoriteBloc>().add(
                    SortFavoriteManga(
                      sortBy: SortingEnum.values[index],
                      order: SortingOrder.values[sortOrderController.selectedIndex ?? 0],
                      nameFilter: nameSortingController.text,
                    ),
                  );
                  sortByController.selectIndex(index);
                },
              );
            },
          ),
          const Divider(),
          GroupButton<SortingOrder>(
            controller: sortOrderController,
            buttons: SortingOrder.values,
            options: const GroupButtonOptions(runSpacing: 0),
            buttonIndexedBuilder: (selected, index, context) {
              return RadioTile(
                title: SortingOrder.values[index].getLocalizedName(),
                selected: sortOrderController.selectedIndex,
                index: index,
                onTap: () {
                  context.read<FavoriteBloc>().add(
                    SortFavoriteManga(
                      sortBy: SortingEnum.values[sortByController.selectedIndex ?? 0],
                      order: SortingOrder.values[index],
                      nameFilter: nameSortingController.text,
                    ),
                  );
                  sortOrderController.selectIndex(index);
                },
              );
            },
          ),
        ],
      ),
    );
  }

  void _onNameFilterChanged() {
    if (_debounceTimer?.isActive ?? false) {
      _debounceTimer?.cancel();
    }

    _debounceTimer = Timer(const Duration(milliseconds: 300), () {
      if (!isNameSortingActive || nameSortingController.text.isEmpty) {
        return;
      }
      if (nameSortingController.text == context.read<FavoriteBloc>().nameFilter) {
        return; // No change in filter
      }

      context.read<FavoriteBloc>().add(
        SortFavoriteManga(
          sortBy: SortingEnum.name,
          order: SortingOrder.values[sortOrderController.selectedIndex ?? 0],
          nameFilter: nameSortingController.text,
        ),
      );
    });
  }
}
