import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'package:shinga/domain/domain.dart';
import 'package:shinga/features/features.dart';

/// Opens the [TitleFilterContent] in a bottom sheet on mobile and in a drawer on wider screens.
Future<void> openTitleFilter({
  required BuildContext context,
  required ValueChanged<TitleFilter> onFilterApply,
}) async {
  final filterCubit = context.read<TitleFilterCubit>();

  var isFilterApplied = false;
  final filterDataSnapshot = filterCubit.state is TitleFilterLoaded
      ? (filterCubit.state as TitleFilterLoaded).draft
      : TitleFilter.empty;

  final isWide = ResponsiveBreakpoints.of(context).largerThan(MOBILE);
  if (isWide) {
    Scaffold.of(context).openEndDrawer();
  } else {
    await showMaterialModalBottomSheet<void>(
      context: context,
      builder: (ctx) => BlocProvider.value(
        value: filterCubit,
        child: SingleChildScrollView(
          controller: ModalScrollController.of(ctx),
          child: TitleFilterContent(
            onApply: (filter) {
              isFilterApplied = true;
              onFilterApply.call(filter);
            },
          ),
        ),
      ),
    ).then((_) {
      if (!isFilterApplied) filterCubit.reset(filterDataSnapshot);
    });
  }
}
