import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/core.dart';
import '../../../i18n/strings.g.dart';
import '../bloc/title_info_bloc.dart';

/// A widget that displays recommended titles in a horizontal scrolling list.
class TitleRecommendationsSection extends StatefulWidget {
  const TitleRecommendationsSection({
    super.key,
    required this.titleId,
  });

  /// The ID of the current title for which recommendations are fetched.
  final String titleId;

  @override
  State<TitleRecommendationsSection> createState() => _TitleRecommendationsSectionState();
}

class _TitleRecommendationsSectionState extends State<TitleRecommendationsSection> {
  bool _hasFetched = false;

  @override
  Widget build(BuildContext context) {
    return ExpandableSection(
      title: t.titleInfo.recommendations.title,
      icon: Icons.recommend_rounded,
      onExpansionChanged: (isExpanded) {
        if (isExpanded && !_hasFetched) {
          context.read<TitleInfoBloc>().add(FetchRecommendationsEvent(widget.titleId));
          _hasFetched = true;
        }
      },
      content: BlocBuilder<TitleInfoBloc, TitleInfoState>(
        builder: (context, state) {
          if (state is RecommendationsLoaded) {
            final content = state.recommendations.content;

            if (content.isEmpty) return _buildEmptyState(context);

            return SizedBox(
              height: 180,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: content.length,
                separatorBuilder: (context, index) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  return TitleCard(
                    width: 120,
                    titleData: content[index],
                    useCoverCache: false,
                  );
                },
              ),
            );
          }

          if (state is RecommendationsFailure) {
            return _buildRetryButton(context, state.error.detail);
          }

          return const Center(
            child: Padding(
              padding: EdgeInsets.only(bottom: 5),
              child: CircularProgressIndicator(),
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final theme = Theme.of(context);

    return Text(
      t.titleInfo.recommendations.noRecommendations,
      style: theme.textTheme.titleMedium.withColor(
        theme.colorScheme.onSurface.withValues(alpha: 0.6),
      ),
    );
  }

  Widget _buildRetryButton(BuildContext context, [String? message]) {
    final theme = Theme.of(context);

    return Column(
      spacing: 10,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (message != null) ...[
          Text(
            message,
            textAlign: TextAlign.center,
            style: theme.textTheme.titleMedium.withColor(
              theme.colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
        ],
        OutlinedButton.icon(
          onPressed: () {
            context.read<TitleInfoBloc>().add(
              FetchRecommendationsEvent(widget.titleId),
            );
          },
          icon: const Icon(Icons.refresh_rounded),
          label: Text(t.common.retry),
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          ),
        ),
      ],
    );
  }
}
