import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

import '../../../../core/core.dart';
import '../../../../data/data.dart';
import '../../../../domain/domain.dart';
import '../../../../i18n/strings.g.dart';

/// A bottom sheet widget that allows users to filter titles based on various criteria.
class TitlesFilterBottomSheet extends StatefulWidget {
  /// Creates a [TitlesFilterBottomSheet] with the given [initialFilter].
  const TitlesFilterBottomSheet({
    super.key,
    required this.initialFilter,
    this.disableBookmarks = false,
  });

  /// Initial filter values for the title search.
  final TitlesFilterFields initialFilter;

  /// Whether to disable bookmark selection.
  final bool disableBookmarks;

  @override
  State<TitlesFilterBottomSheet> createState() => _TitlesFilterBottomSheetState();
}

class _TitlesFilterBottomSheetState extends State<TitlesFilterBottomSheet> {
  final _formKey = GlobalKey<FormBuilderState>();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocProvider(
      create: (context) => TitlesFilterCubit(getIt<RestClient>())..loadFilterData(),
      child: SafeArea(
        top: false,
        minimum: const EdgeInsets.all(15),
        child: FormBuilder(
          key: _formKey,
          initialValue: widget.initialFilter.toFormValues(),
          child: ListView(
            shrinkWrap: true,
            physics: const ClampingScrollPhysics(),
            children: [
              Text(
                t.searching.searchFilter.title,
                style: theme.textTheme.titleLarge.semiBold,
              ),
              const SizedBox(height: 15),
              BlocBuilder<TitlesFilterCubit, TitlesFilterState>(
                builder: (context, state) {
                  if (state is TitlesFilterDataLoading) {
                    return const SizedBox.square(
                      dimension: 50,
                      child: Center(
                        child: CircularProgressIndicator(),
                      ),
                    );
                  }
                  if (state is! TitlesFilterDataLoaded) {
                    return const SizedBox.shrink();
                  }

                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      FormBuilderListTile(
                        name: 'type_',
                        title: t.searching.searchFilter.types,
                        onTap: () => _openMultiSelectSheetForTitleType(
                          title: t.searching.searchFilter.types,
                          options: state.types,
                          fieldName: 'type_',
                        ),
                      ),
                      FormBuilderListTile(
                        name: 'genres',
                        title: t.searching.searchFilter.genres,
                        onTap: () => _openMultiSelectSheetForStrings(
                          title: t.searching.searchFilter.genres,
                          options: state.genres,
                          fieldName: 'genres',
                        ),
                      ),
                      FormBuilderListTile(
                        name: 'status',
                        title: t.searching.searchFilter.statuses,
                        onTap: () => _openMultiSelectSheetForTitleStatus(
                          title: t.searching.searchFilter.statuses,
                          options: state.statuses,
                          fieldName: 'status',
                        ),
                      ),
                    ],
                  );
                },
              ),
              const Divider(),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  t.titleInfo.rating,
                  style: theme.textTheme.bodyLarge,
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: FormBuilderTextField(
                      name: 'min_rating',
                      decoration: InputDecoration(
                        labelText: t.common.from,
                      ),
                      validator: TextFieldFilterService.sliceNum(1, 10),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: FormBuilderTextField(
                      name: 'max_rating',
                      decoration: InputDecoration(
                        labelText: t.common.to,
                      ),
                      validator: TextFieldFilterService.sliceNum(1, 10),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 15),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  t.titleInfo.chapters,
                  style: theme.textTheme.bodyLarge,
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: FormBuilderTextField(
                      name: 'min_chapters',
                      decoration: InputDecoration(
                        labelText: t.common.from,
                      ),
                      validator: TextFieldFilterService.minNum(1),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: FormBuilderTextField(
                      name: 'max_chapters',
                      decoration: InputDecoration(
                        labelText: t.common.to,
                      ),
                      validator: TextFieldFilterService.minNum(1),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),
              const Divider(),
              Text(
                t.searching.sorting.title,
                style: theme.textTheme.titleLarge.semiBold,
              ),
              const SizedBox(height: 10),
              FormBuilderDropdown<String>(
                name: 'sort_by',
                decoration: InputDecoration(
                  labelText: t.searching.sorting.sortBy,
                ),
                dropdownColor: theme.scaffoldBackgroundColor,
                items: TitleSortBy.values.map((item) {
                  return DropdownMenuItem<String>(
                    value: item.value,
                    child: Text(item.i18n),
                  );
                }).toList(),
              ),
              const SizedBox(height: 10),
              FormBuilderDropdown<String>(
                name: 'sort_order',
                decoration: InputDecoration(
                  labelText: t.searching.sorting.sortOrder,
                ),
                dropdownColor: theme.scaffoldBackgroundColor,
                items: TitleSortOrder.values.map((item) {
                  return DropdownMenuItem<String>(
                    value: item.name,
                    child: Text(item.i18n),
                  );
                }).toList(),
              ),
              if (!widget.disableBookmarks) ...[
                const SizedBox(height: 10),
                FormBuilderDropdown<BookMarkType>(
                  name: 'bookmark',
                  decoration: InputDecoration(
                    labelText: t.searching.sorting.bookmark,
                  ),
                  dropdownColor: theme.scaffoldBackgroundColor,
                  items: BookMarkType.values.map((item) {
                    return DropdownMenuItem<BookMarkType>(
                      value: item,
                      child: Text(item.i18n),
                    );
                  }).toList(),
                ),
              ],
              const Divider(height: 30),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _resetFields,
                      child: Text(t.searching.searchFilter.reset),
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: FilledButton(
                      onPressed: _onApply,
                      child: Text(t.searching.searchFilter.apply),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Handle the apply button action
  void _onApply() {
    final result = _formKey.currentState?.saveAndValidate();
    if (result != true) return;

    final formData = _formKey.currentState?.value;
    final filterData = TitlesFilterFields(
      type: formData?['type_'] as List<String>?,
      genres: formData?['genres'] as List<String>?,
      status: formData?['status'] as List<String>?,
      minRating: _parseDouble(formData?['min_rating']),
      maxRating: _parseDouble(formData?['max_rating']),
      minChapters: _parseInt(formData?['min_chapters']),
      maxChapters: _parseInt(formData?['max_chapters']),
      sortBy: formData?['sort_by'] as String?,
      sortOrder: formData?['sort_order'] as String?,
      bookmark: formData?['bookmark'] as BookMarkType?,
    );

    context.router.pop(filterData);
  }

  /// Reset the form fields to null values
  void _resetFields() {
    _formKey.currentState?.fields.forEach((key, field) {
      field.didChange(null);
    });
  }

  // Helper methods to open multi-select sheets for different fields
  void _openMultiSelectSheetForTitleType({
    required String title,
    required List<TitleType> options,
    required String fieldName,
  }) {
    final currentValues = _formKey.currentState?.fields[fieldName]?.value as List<String>? ?? [];
    final selectedTypes = currentValues
        .map(
          (value) => options.firstWhere(
            (type) => type.value == value,
            orElse: () => TitleType.other,
          ),
        )
        .toList();

    showMaterialModalBottomSheet<void>(
      context: context,
      builder: (context) {
        return MultiSelectBottomSheet<TitleType>(
          title: title,
          options: options,
          selectedValues: selectedTypes,
          displayText: (type) => type.i18n,
          onChanged: (selectedTypes) {
            final selectedValues = selectedTypes.map((type) => type.value).toList();
            _formKey.currentState?.fields[fieldName]?.didChange(selectedValues);
          },
        );
      },
    );
  }

  void _openMultiSelectSheetForTitleStatus({
    required String title,
    required List<TitleStatus> options,
    required String fieldName,
  }) {
    final currentValues = _formKey.currentState?.fields[fieldName]?.value as List<String>? ?? [];
    final selectedStatuses = currentValues
        .map(
          (value) => options.firstWhere(
            (status) => status.value == value,
            orElse: () => TitleStatus.unknown,
          ),
        )
        .toList();

    showMaterialModalBottomSheet<void>(
      context: context,
      builder: (context) {
        return MultiSelectBottomSheet<TitleStatus>(
          title: title,
          options: options,
          selectedValues: selectedStatuses,
          displayText: (status) => status.i18n,
          onChanged: (selectedStatuses) {
            final selectedValues = selectedStatuses.map((status) => status.value).toList();
            _formKey.currentState?.fields[fieldName]?.didChange(selectedValues);
          },
        );
      },
    );
  }

  void _openMultiSelectSheetForStrings({
    required String title,
    required List<String> options,
    required String fieldName,
  }) {
    final currentValues = _formKey.currentState?.fields[fieldName]?.value as List<String>? ?? [];

    showMaterialModalBottomSheet<void>(
      context: context,
      builder: (context) {
        return MultiSelectBottomSheet<String>(
          title: title,
          options: options,
          selectedValues: currentValues,
          displayText: (value) => value,
          onChanged: (selectedValues) {
            _formKey.currentState?.fields[fieldName]?.didChange(selectedValues);
          },
        );
      },
    );
  }

  /// Helper methods to parse double values from dynamic input
  double? _parseDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is String && value.isNotEmpty) {
      return double.tryParse(value);
    }
    return null;
  }

  /// Helper method to parse int values from dynamic input
  int? _parseInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is String && value.isNotEmpty) {
      return int.tryParse(value);
    }
    return null;
  }
}
