import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shinga/core/core.dart';
import 'package:shinga/domain/domain.dart';
import 'package:shinga/features/features.dart';

/// The title search page for searching manga titles.
@RoutePage()
class TitleSearchPage extends StatelessWidget {
  /// Creates a [TitleSearchPage] widget.
  const TitleSearchPage({super.key});

  @override
  Widget build(BuildContext context) {
    final deps = context.deps;
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => TitleFilterCubit(deps.titleFilterRepository)),
        BlocProvider(create: (_) => TitleSearchBloc(deps.titleRepository)),
        BlocProvider(
          create: (_) {
            final cubit = TitleSearchHistoryCubit(deps.searchHistoryRepository);
            unawaited(cubit.loadHistory());
            return cubit;
          },
        ),
      ],
      child: const _TitleSearchView(),
    );
  }
}

class _TitleSearchView extends StatefulWidget {
  const _TitleSearchView();

  @override
  State<_TitleSearchView> createState() => _TitleSearchViewState();
}

class _TitleSearchViewState extends State<_TitleSearchView> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: TitleSearchAppBar(
        controller: _controller,
        onSearchFilterApply: _onSearchFilterApply,
      ),
      endDrawer: TitleFilterDrawer(
        onFilterApply: _onSearchFilterApply,
      ),
      body: SafeArea(
        child: BlocConsumer<TitleSearchBloc, TitleSearchState>(
          listenWhen: (prev, curr) => curr.query.isNotEmpty && prev.query != curr.query,
          listener: (context, state) =>
              context.read<TitleSearchHistoryCubit>().addSearchQuery(state.query),
          builder: (_, state) {
            if (state.query.isNotEmpty || state.filter != TitleFilter.empty) {
              return const TitleSearchResultContent();
            } else {
              return TitleSearchHistoryContent(onHistoryTileTap: _onHistoryTileTap);
            }
          },
        ),
      ),
    );
  }

  void _onSearchFilterApply(TitleFilter filter) {
    context.read<TitleSearchBloc>().add(TitleSearchFilterApplied(filter));
    context.router.pop();
  }

  Future<void> _onHistoryTileTap(String query) async {
    _controller.text = query;
    await context.read<TitleSearchHistoryCubit>().addSearchQuery(query);
  }
}
