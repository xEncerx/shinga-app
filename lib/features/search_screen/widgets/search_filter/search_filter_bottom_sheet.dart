import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

import '../../../../core/core.dart';
import '../../../../data/data.dart';
import '../../../../domain/domain.dart';
import '../../../../i18n/strings.g.dart';
import '../../../features.dart';

class SearchFilterBottomSheet extends StatefulWidget {
  const SearchFilterBottomSheet({
    super.key,
    required this.initialFilter,
  });

  final SearchTitleFields initialFilter;

  @override
  State<SearchFilterBottomSheet> createState() => _SearchFilterBottomSheetState();
}

class _SearchFilterBottomSheetState extends State<SearchFilterBottomSheet> {
  final _formKey = GlobalKey<FormBuilderState>();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocProvider(
      create: (context) => SearchFilterBloc(restClient: getIt<RestClient>())..add(LoadFilterData()),
      child: SafeArea(
        top: false,
        minimum: const EdgeInsets.all(15),
        child: FormBuilder(
          key: _formKey,
          initialValue: _loadInitialValues(),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                t.searching.searchFilter.title,
                style: theme.textTheme.titleLarge.semiBold,
              ),
              const SizedBox(height: 15),
              BlocBuilder<SearchFilterBloc, SearchFilterState>(
                builder: (context, state) {
                  if (state is! FilterDataLoaded) {
                    return const CircularProgressIndicator();
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
                items: [
                  DropdownMenuItem<String>(
                    value: 'rating',
                    child: Text(
                      t.searching.sorting.rating,
                    ),
                  ),
                  DropdownMenuItem<String>(
                    value: 'popularity',
                    child: Text(t.searching.sorting.popularity),
                  ),
                  DropdownMenuItem<String>(
                    value: 'favorites',
                    child: Text(t.searching.sorting.favorites),
                  ),
                  DropdownMenuItem<String>(
                    value: 'chapters',
                    child: Text(t.searching.sorting.chapters),
                  ),
                  DropdownMenuItem<String>(value: 'views', child: Text(t.searching.sorting.views)),
                ],
              ),
              const SizedBox(height: 10),
              FormBuilderDropdown<String>(
                name: 'sort_order',
                decoration: InputDecoration(
                  labelText: t.searching.sorting.sortOrder,
                ),
                items: [
                  DropdownMenuItem<String>(
                    value: 'asc',
                    child: Text(t.searching.sorting.ascending),
                  ),
                  DropdownMenuItem<String>(
                    value: 'desc',
                    child: Text(t.searching.sorting.descending),
                  ),
                ],
              ),
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

  /// Get initial values for the form fields based on the initial filter
  Map<String, dynamic> _loadInitialValues() {
    final initFilter = widget.initialFilter;
    return {
      'type_': initFilter.type ?? [],
      'genres': initFilter.genres ?? [],
      'status': initFilter.status ?? [],
      'min_rating': initFilter.minRating?.toString() ?? '',
      'max_rating': initFilter.maxRating?.toString() ?? '',
      'min_chapters': initFilter.minChapters?.toString() ?? '',
      'max_chapters': initFilter.maxChapters?.toString() ?? '',
      'sort_by': initFilter.sortBy,
      'sort_order': initFilter.sortOrder,
    };
  }

  /// Handle the apply button action
  void _onApply() {
    final result = _formKey.currentState?.saveAndValidate();
    if (result != true) return;

    final formData = _formKey.currentState?.value;
    final filterData = SearchTitleFields(
      type: formData?['type_'] as List<String>?,
      genres: formData?['genres'] as List<String>?,
      status: formData?['status'] as List<String>?,
      minRating: _parseDouble(formData?['min_rating']),
      maxRating: _parseDouble(formData?['max_rating']),
      minChapters: _parseInt(formData?['min_chapters']),
      maxChapters: _parseInt(formData?['max_chapters']),
      sortBy: formData?['sort_by'] as String?,
      sortOrder: formData?['sort_order'] as String?,
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

  // Helper methods to parse double and int values from dynamic input
  double? _parseDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is String && value.isNotEmpty) {
      return double.tryParse(value);
    }
    return null;
  }

  int? _parseInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is String && value.isNotEmpty) {
      return int.tryParse(value);
    }
    return null;
  }
}
