import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shinga/domain/domain.dart';
import 'package:shinga/features/features.dart';
import 'package:ui_kit/ui_kit.dart';

/// A drawer that contains the [TitleFilterContent]. Used on wider screens in [openTitleFilter].
class TitleFilterDrawer extends StatefulWidget {
  /// Creates a [TitleFilterDrawer] widget.
  const TitleFilterDrawer({required this.onFilterApply, super.key});

  /// Called when the filter is applied. The [TitleFilter] passed to the callback is the one that should be applied to the title list.
  final ValueChanged<TitleFilter> onFilterApply;

  @override
  State<TitleFilterDrawer> createState() => _TitleFilterDrawerState();
}

class _TitleFilterDrawerState extends State<TitleFilterDrawer> {
  bool _isFilterApplied = false;
  late TitleFilter _filterDataSnapshot;
  late TitleFilterCubit _filterCubit;

  @override
  void initState() {
    _filterCubit = context.read<TitleFilterCubit>();

    _filterDataSnapshot = _filterCubit.state is TitleFilterLoaded
        ? (_filterCubit.state as TitleFilterLoaded).draft
        : TitleFilter.empty;
    super.initState();
  }

  @override
  void dispose() {
    if (!_isFilterApplied) _filterCubit.reset(_filterDataSnapshot);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: context.colors.surface,
      child: SingleChildScrollView(
        child: TitleFilterContent(
          onApply: (filter) {
            _isFilterApplied = true;
            widget.onFilterApply.call(filter);
          },
        ),
      ),
    );
  }
}
