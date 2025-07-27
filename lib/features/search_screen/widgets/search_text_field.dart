import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

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
    widget.focusNode.addListener(() {
      setState(() {});
    });
    widget.controller.addListener(() {
      final prevData = context.read<SearchBloc>().searchData;
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
    final t = Translations.of(context);

    return TextField(
      controller: widget.controller,
      focusNode: widget.focusNode,
      autofocus: true,
      onTapOutside: (event) => widget.focusNode.unfocus(),
      decoration: InputDecoration(
        hintText: t.searching.buttonText,
        prefixIcon: IconButton(
          onPressed: () => context.router.pop(),
          icon: Icon(
            Icons.arrow_back,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        suffixIcon: AnimatedCrossFade(
          firstChild: IconButton(
            onPressed: () {
              widget.controller.clear();
              context.read<SearchBloc>().add(LoadSearchHistory());
            },
            icon: Icon(
              Icons.close,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          secondChild: const SizedBox.shrink(),
          crossFadeState: widget.focusNode.hasFocus
              ? CrossFadeState.showFirst
              : CrossFadeState.showSecond,
          duration: const Duration(milliseconds: 100),
        ),
      ),
    );
  }
}
