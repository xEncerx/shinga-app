import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';

import '../../../../core/core.dart';
import '../../../../i18n/strings.g.dart';

/// A bottom sheet widget that allows users to select multiple options from a list.
class MultiSelectBottomSheet<T> extends StatefulWidget {
  const MultiSelectBottomSheet({
    super.key,
    required this.title,
    required this.options,
    required this.selectedValues,
    required this.onChanged,
    required this.displayText,
  });

  /// The title of the bottom sheet.
  final String title;
  /// The list of options to choose from.
  final List<T> options;
  /// The currently selected values.
  final List<T> selectedValues;
  /// Callback function that is called when the selected values change.
  final ValueChanged<List<T>> onChanged;
  /// A function that returns the display text for each option.
  final String Function(T) displayText;

  @override
  State<MultiSelectBottomSheet<T>> createState() => _MultiSelectBottomSheetState<T>();
}

class _MultiSelectBottomSheetState<T> extends State<MultiSelectBottomSheet<T>> {
  late List<T> _selectedValues;

  @override
  void initState() {
    super.initState();
    _selectedValues = List.from(widget.selectedValues);
  }

  void _toggleSelection(T value) {
    setState(() {
      if (_selectedValues.contains(value)) {
        _selectedValues.remove(value);
      } else {
        _selectedValues.add(value);
      }
    });
    widget.onChanged(_selectedValues);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_rounded),
            onPressed: () => context.router.pop(),
          ),
          actions: [
            TextButton(
              onPressed: () {
                setState(() => _selectedValues.clear());
                widget.onChanged(_selectedValues);
              },
              child: Text(
                t.searching.searchFilter.clearAll,
                style: theme.textTheme.bodyMedium.withColor(theme.colorScheme.primary),
              ),
            ),
          ],
        ),
        body: ListView.builder(
          itemCount: widget.options.length,
          itemBuilder: (context, index) {
            final option = widget.options[index];
            final isSelected = _selectedValues.contains(option);

            return CheckboxListTile(
              title: Text(widget.displayText(option)),
              value: isSelected,
              onChanged: (_) => _toggleSelection(option),
              controlAffinity: ListTileControlAffinity.leading,
            );
          },
        ),
      ),
    );
  }
}
