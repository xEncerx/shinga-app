import 'package:flutter/material.dart';
import 'package:ui_kit/ui_kit.dart';

/// A multi-select dialog with search functionality.
///
/// Returns a [List<T>] containing the selected items when the user presses apply.
class SaSearchableMultiSelectDialog<T> extends StatefulWidget {
  /// Creates a [SaSearchableMultiSelectDialog] widget.
  const SaSearchableMultiSelectDialog({
    required this.items,
    required this.itemLabelBuilder,
    this.searchFunction,
    this.initialSelectedItems = const [],
    this.title = 'Select items',
    this.searchHint = 'Search',
    this.applyText = 'Apply',
    this.resetText = 'Reset',
    super.key,
  });

  /// The list of items to select from.
  final List<T> items;

  /// The initially selected items.
  final List<T> initialSelectedItems;

  /// A function that returns the display label for an item.
  final String Function(T) itemLabelBuilder;

  /// An optional function that performs search on the items.
  ///
  /// If not provided, the dialog will perform a simple case-insensitive substring match on the labels.
  final Iterable<T> Function(String query)? searchFunction;

  /// The title of the dialog.
  final String title;

  /// The hint text for the search field.
  final String searchHint;

  /// The text for the apply button.
  final String applyText;

  /// The text for the reset button.
  final String resetText;

  @override
  State<SaSearchableMultiSelectDialog<T>> createState() => _SaSearchableMultiSelectDialogState<T>();
}

class _SaSearchableMultiSelectDialogState<T> extends State<SaSearchableMultiSelectDialog<T>> {
  final TextEditingController _searchController = TextEditingController();
  late List<T> _filteredItems;
  late final List<T> _selectedItems;

  @override
  void initState() {
    _selectedItems = List.of(widget.initialSelectedItems);
    _filteredItems = List.of(widget.items);
    super.initState();
  }

  void _onSearch(String query) {
    setState(() {
      if (widget.searchFunction != null) {
        _filteredItems = widget.searchFunction!(query).toList();
      } else {
        _filteredItems = widget.items.where((item) {
          final label = widget.itemLabelBuilder(item).toLowerCase();
          return label.contains(query.toLowerCase());
        }).toList();
      }
    });
  }

  void _onReset() {
    setState(() {
      _searchController.clear();
      _selectedItems.clear();
      _filteredItems = List.of(widget.items);
    });
  }

  void _onApply() => Navigator.of(context).pop(_selectedItems);

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SaAppDialog(
      title: Wrap(
        crossAxisAlignment: WrapCrossAlignment.center,
        alignment: WrapAlignment.spaceBetween,
        children: [
          SaText(widget.title, style: AppTextStyle.title),
          SaIconButton(
            icon: const SaIcon(icon: SaIconSource.material(Icons.close)),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
      content: SizedBox(
        width: double.maxFinite,
        child: Column(
          spacing: AppSpacing.s,
          children: [
            SaTextField(
              controller: _searchController,
              hintText: widget.searchHint,
              prefixIcon: const SaIcon(icon: SaIconSource.huge(HugeIconsStrokeRounded.search01)),
              onChanged: _onSearch,
            ),
            Flexible(
              child: GridView.builder(
                shrinkWrap: true,
                gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 250,
                  crossAxisSpacing: AppSpacing.xs,
                  mainAxisSpacing: AppSpacing.xs,
                  mainAxisExtent: 48,
                ),
                itemCount: _filteredItems.length,
                itemBuilder: (context, index) {
                  final item = _filteredItems[index];
                  final isSelected = _selectedItems.contains(item);
                  return SaCheckboxListTile(
                    value: isSelected,
                    title: SaText(
                      widget.itemLabelBuilder(item),
                      style: AppTextStyle.body,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    onChanged: (selected) {
                      setState(() {
                        if (selected == true) {
                          _selectedItems.add(item);
                        } else {
                          _selectedItems.remove(item);
                        }
                      });
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
      actions: [
        SaTextButton(
          onPressed: _onReset,
          child: SaText(widget.resetText),
        ),
        SaPrimaryButton(
          width: 120,
          onPressed: _onApply,
          child: SaText(widget.applyText),
        ),
      ],
    );
  }
}
