import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shinga/domain/domain.dart';
import 'package:shinga/features/features.dart';
import 'package:shinga/i18n/strings.g.dart';
import 'package:ui_kit/ui_kit.dart';

/// The search app bar widget for title search.
class TitleSearchAppBar extends StatefulWidget implements PreferredSizeWidget {
  /// Creates a [TitleSearchAppBar] widget.
  const TitleSearchAppBar({
    required this.controller,
    required this.onSearchFilterApply,
    super.key,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  /// The text controller for the search input.
  final TextEditingController controller;

  /// Callback invoked when a filter is applied.
  final ValueChanged<TitleFilter> onSearchFilterApply;

  @override
  State<TitleSearchAppBar> createState() => _TitleSearchAppBarState();
}

class _TitleSearchAppBarState extends State<TitleSearchAppBar> {
  String _lastQuery = '';

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onSearchQueryChanged);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onSearchQueryChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colors;
    final t = Translations.of(context);

    return AppBar(
      automaticallyImplyLeading: false,
      automaticallyImplyActions: false,
      title: SaTextField(
        controller: widget.controller,
        autofocus: true,
        decoration: InputDecoration(
          contentPadding: const EdgeInsets.only(top: AppSpacing.m),
          hintText: t.titleSearch.searchBarTitle,
          hintStyle: AppTextStyle.titleM.copyWith(color: colorScheme.onSurfaceVariant),
          prefixIconColor: colorScheme.onSurfaceVariant,
          suffixIconColor: colorScheme.onSurfaceVariant,
          prefixIcon: const SaBackButton(),
          suffixIcon: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (widget.controller.text.isNotEmpty)
                SaIconButton(
                  icon: const SaIcon(
                    icon: SaIconSource.huge(HugeIconsStrokeRounded.cancel01),
                  ),
                  onPressed: () => widget.controller.clear(),
                ),
              SaIconButton(
                icon: const SaIcon(
                  icon: SaIconSource.huge(HugeIconsStrokeRounded.filter),
                ),
                onPressed: () =>
                    openTitleFilter(context: context, onFilterApply: widget.onSearchFilterApply),
              ),
            ],
          ),
          border: const UnderlineInputBorder(),
        ),
      ),
    );
  }

  void _onSearchQueryChanged() {
    final currentText = widget.controller.text;

    if (currentText != _lastQuery) {
      _lastQuery = currentText;
      context.read<TitleSearchBloc>().add(TitleSearchQueryChanged(currentText));
      setState(() {});
    }
  }
}
