import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shinga/domain/domain.dart';
import 'package:shinga/features/features.dart';
import 'package:ui_kit/ui_kit.dart';

/// A widget displaying the search results list.
class TitleSearchResultContent extends StatelessWidget {
  /// Creates a [TitleSearchResultContent] widget.
  const TitleSearchResultContent({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.s),
      child: BlocSelector<AppSettingsCubit, AppSettingsState, TitleButtonStyle>(
        selector: (state) => state.settings.titleButtonStyle,
        builder: (_, buttonStyle) => BlocBuilder<TitleSearchBloc, TitleSearchState>(
          builder: (_, state) => TitlePagedList(
            state: state.pagingState,
            useCoverCache: false,
            buttonStyle: buttonStyle,
            onFetchPage: () => context.read<TitleSearchBloc>().add(TitleSearchFetchNextPage()),
            onRefresh: () => context.read<TitleSearchBloc>().add(TitleSearchRefreshed()),
          ),
        ),
      ),
    );
  }
}
