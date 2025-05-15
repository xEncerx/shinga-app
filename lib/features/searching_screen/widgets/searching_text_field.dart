import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';

import '../../../i18n/strings.g.dart';

class SearchingTextField extends StatelessWidget {
  const SearchingTextField({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.onSubmitted,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final void Function(String text) onSubmitted;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return TextField(
      controller: controller,
      focusNode: focusNode,
      onSubmitted: onSubmitted,
      autofocus: true,
      decoration: InputDecoration(
        filled: false,
        contentPadding: const EdgeInsets.only(top: 12),
        hintStyle: theme.textTheme.titleSmall,
        hintText: t.favorite.searchManga,
        enabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: theme.primaryColor),
        ),
        focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: theme.primaryColor),
        ),
        prefixIcon: IconButton(
          onPressed: () => context.router.pop(),
          icon: const Icon(Icons.arrow_back),
        ),
        suffixIcon: IconButton(
          onPressed: controller.clear,
          icon: const Icon(Icons.close_rounded),
        ),
      ),
    );
  }
}
