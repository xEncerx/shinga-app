import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shinga/features/features.dart';
import 'package:shinga/i18n/i18n.dart';
import 'package:shinga/i18n/strings.g.dart';
import 'package:ui_kit/ui_kit.dart';

/// A widget displaying the search history list.
class TitleSearchHistoryContent extends StatelessWidget {
  /// Creates a [TitleSearchHistoryContent] widget.
  const TitleSearchHistoryContent({
    required this.onHistoryTileTap,
    super.key,
  });

  /// Callback invoked when a history item is tapped.
  final ValueChanged<String> onHistoryTileTap;

  @override
  Widget build(BuildContext context) {
    final t = Translations.of(context);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(AppSpacing.s),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SaText(
                t.titleSearch.historyTitle,
                style: AppTextStyle.body,
              ),
              SaTextButton(
                onPressed: () => context.read<TitleSearchHistoryCubit>().clearHistory(),
                child: SaText(
                  t.titleSearch.historyClear,
                  style: AppTextStyle.body,
                ),
              ),
            ],
          ),
        ),
        BlocBuilder<TitleSearchHistoryCubit, TitleSearchHistoryState>(
          builder: (_, state) {
            if (state is TitleSearchHistoryError) {
              final message = state.failure.toMessage();

              return SaStateMessage.error(
                title: message.title,
                description: message.description,
              );
            } else if (state is TitleSearchHistoryLoaded) {
              return Expanded(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: state.history.length,
                  itemBuilder: (_, index) {
                    final title = state.history[index];
                    return TitleSearchHistoryTile(
                      title: title.query,
                      onTap: () => onHistoryTileTap(title.query),
                      onDelete: () =>
                          context.read<TitleSearchHistoryCubit>().deleteHistoryItem(title),
                    );
                  },
                ),
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ],
    );
  }
}
