import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/extensions/extensions.dart';
import '../../../i18n/strings.g.dart';
import '../search_screen.dart';

class HistoryList extends StatelessWidget {
  const HistoryList({
    super.key,
    required this.history,
    required this.onTap,
  });

  final List<String?> history;
  final void Function(String text) onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 5),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text(
                  t.searching.history,
                  style: theme.textTheme.labelSmall.ellipsis,
                ),
              ),
              TextButton(
                onPressed: () => context.read<SearchBloc>().add(
                  ClearSearchingHistory(),
                ),
                child: Text(
                  t.searching.clearHistory,
                  style: theme.textTheme.labelMedium,
                ),
              ),
            ],
          ),
          Expanded(
            child: ListView.builder(
              itemCount: history.length,
              itemBuilder: (context, index) {
                return HistoryTile(
                  text: history[index] ?? '',
                  onTap: () => onTap(history[index] ?? ''),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
