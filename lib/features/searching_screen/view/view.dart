import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:get_it/get_it.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:talker/talker.dart';

import '../../../core/core.dart';
import '../../../data/data.dart';
import '../../../domain/domain.dart';
import '../../../i18n/strings.g.dart';
import '../searching_screen.dart';

@RoutePage()
class SearchingScreen extends StatefulWidget {
  const SearchingScreen({super.key});

  @override
  State<SearchingScreen> createState() => _SearchingScreenState();
}

class _SearchingScreenState extends State<SearchingScreen> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();

  @override
  void initState() {
    context.read<SearchingBloc>().add(LoadSearchingHistory());
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return PopScope(
      onPopInvoked: (didPop) {
        context.read<SearchingBloc>().lastSearchQuery = '';
      },
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: TypeAheadField<String?>(
            focusNode: _focusNode,
            controller: _controller,
            hideOnEmpty: true,
            suggestionsCallback: (v) => _suggestName(v),
            loadingBuilder: (context) => SizedBox(
              height: 40,
              child: Center(
                child: LoadingAnimationWidget.progressiveDots(
                  color: theme.primaryColor,
                  size: 40,
                ),
              ),
            ),
            itemBuilder: (context, suggestion) {
              return ListTile(
                title: Text(
                  suggestion ?? '',
                  style: theme.textTheme.titleSmall,
                ),
              );
            },
            onSelected: (v) {
              _controller.text = v ?? '';
              _search();
            },
            builder: (context, controller, focusNode) => SearchingTextField(
              controller: controller,
              focusNode: focusNode,
              onSubmitted: (_) => _search(),
            ),
          ),
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 10,
              vertical: 5,
            ),
            child: BlocBuilder<SearchingBloc, SearchingState>(
              builder: (context, state) {
                if (state is SearchingError) {
                  GetIt.I<Talker>().error(
                    'Searching error: ${state.error}',
                  );
                  return ErrorNotifyContainer(
                    title: t.errorWidget.searchingError.title,
                    description: t.errorWidget.searchingError.description,
                  );
                }
                if (state is SearchingMangaLoaded) {
                  // Empty list error widget
                  return MangaList(
                    mangaListData: state.manga,
                  );
                }
                if (state is SearchingHistoryLoaded) {
                  if (state.history.isEmpty) {
                    return ErrorNotifyContainer(
                      title: t.errorWidget.historyEmpty.title,
                      description: t.errorWidget.historyEmpty.description,
                    );
                  }
                  
                  return HistoryList(
                    history: state.history,
                    onTap: (text) {
                      _controller.text = text;
                      _search();
                    },
                  );
                }
                return Center(
                  child: LoadingAnimationWidget.threeArchedCircle(
                    color: theme.primaryColor,
                    size: 50,
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  void _search() {
    if (_controller.text.isNotEmpty) {
      context.read<SearchingBloc>().add(
            AddSearchingHistoryValue(_controller.text),
          );
      context.read<SearchingBloc>().add(
            SearchManga(_controller.text),
          );
      _focusNode.unfocus();
    }
  }

  Future<List<String?>> _suggestName(String v) async {
    if (v.isNotEmpty) {
      final result = await GetIt.I<MangaRepository>().suggestName(
        query: v,
        source: GetIt.I<SettingsRepository>().getAppSettings().suggestProvider,
      );
      return result.fold(
        (l) => [],
        (r) => r.content,
      );
    }
    return [];
  }
}
