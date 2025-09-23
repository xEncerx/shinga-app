import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

import '../../../core/core.dart';
import '../../../data/data.dart';
import '../../../i18n/strings.g.dart';
import '../../features.dart';

class SearchTextField extends StatefulWidget {
  const SearchTextField({
    super.key,
    required this.controller,
    required this.focusNode,
  });

  final TextEditingController controller;
  final FocusNode focusNode;

  @override
  State<SearchTextField> createState() => _SearchTextFieldState();
}

class _SearchTextFieldState extends State<SearchTextField> {
  @override
  void initState() {
    super.initState();
    widget.controller.addListener(() {
      setState(() {});
      final prevData = context.read<SearchBloc>().filterData;
      if (widget.controller.text.isNotEmpty && widget.controller.text != prevData.query) {
        context.read<SearchBloc>().add(
          FetchSearchTitles(
            prevData.copyWith(query: widget.controller.text),
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final t = Translations.of(context);

    return TextField(
      controller: widget.controller,
      focusNode: widget.focusNode,
      autofocus: true,
      onTapOutside: (event) => widget.focusNode.unfocus(),
      decoration: InputDecoration(
        fillColor: Colors.transparent,
        hoverColor: Colors.transparent,
        border: const UnderlineInputBorder(),
        hintText: t.searching.buttonText,
        prefixIcon: IconButton(
          onPressed: () => context.router.pop(),
          icon: Icon(
            Icons.arrow_back,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        suffixIcon: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedCrossFade(
              firstChild: IconButton(
                onPressed: () {
                  widget.controller.clear();
                  context.read<SearchBloc>().add(LoadSearchHistory());
                },
                icon: Icon(
                  Icons.close,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              secondChild: const SizedBox.shrink(),
              crossFadeState: widget.controller.text.isNotEmpty
                  ? CrossFadeState.showFirst
                  : CrossFadeState.showSecond,
              duration: const Duration(milliseconds: 100),
            ),
            IconButton(
              onPressed: () => _openFilterBottomSheet(context),
              icon: Icon(
                Icons.filter_alt,
                color: theme.colorScheme.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _openFilterBottomSheet(BuildContext context) async {
    final searchBloc = context.read<SearchBloc>();
    final filterData = searchBloc.filterData;
    final result = await showMaterialModalBottomSheet<TitlesFilterFields>(
      context: context,
      builder: (context) {
        return TitlesFilterBottomSheet(
          initialFilter: filterData,
        );
      },
    );

    if (context.mounted && result != null) {
      searchBloc.add(
        FetchSearchTitles(result.copyWith(query: filterData.query)),
      );
    }
  }
}
