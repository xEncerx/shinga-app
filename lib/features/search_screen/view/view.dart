import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/core.dart';
import '../../../data/data.dart';
import '../../features.dart';

@RoutePage()
class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => SearchBloc(
        getIt<RestClient>(),
        getIt<SearchHistoryRepository>(),
      )..add(LoadSearchHistory()),
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: SearchTextField(
            controller: _controller,
            focusNode: _focusNode,
          ),
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(5),
            child: BlocBuilder<SearchBloc, SearchState>(
              builder: (context, state) {
                final searchData = context.read<SearchBloc>().searchData;

                if (state is SearchInitial) {
                  return HistoryList(
                    history: state.history,
                    onTap: (query) {
                      _controller.text = query;
                      _focusNode.unfocus();
                      context.read<SearchBloc>().add(
                        FetchSearchTitles(searchData.copyWith(query: query)),
                      );
                    },
                  );
                } else if (state is SearchPaginationState) {
                  return PagedTitleList(
                    state: state.pagingState,
                    onRefresh: () => context.read<SearchBloc>().add(
                      FetchSearchTitles(searchData),
                    ),
                    onFetchPage: () => context.read<SearchBloc>().add(
                      LoadMoreSearchTitles(),
                    ),
                    useCoverCache: false,
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ),
        ),
      ),
    );
  }
}
