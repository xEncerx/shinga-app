import 'package:flutter/material.dart';
import 'package:readmore/readmore.dart';

import '../../../core/core.dart';
import '../../../data/data.dart';
import '../../../i18n/strings.g.dart';

/// A widget that displays the genres, authors, and description of a title.
class TitleGADSection extends StatelessWidget {
  const TitleGADSection({
    super.key,
    required this.genres,
    required this.authors,
    required this.description,
    required this.locale,
  });

  /// List of genres associated with the title.
  final List<GenreData> genres;

  /// List of authors associated with the title.
  final List<String> authors;

  /// Description of the title.
  final DescriptionData description;

  /// Current locale to determine language for display.
  final AppLocale locale;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SizedBox(
      width: double.infinity,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: theme.colorScheme.primary.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            spacing: 10,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Genres Section
              IconWithText(
                text: t.titleInfo.genres,
                icon: Icon(
                  Icons.category_rounded,
                  size: 22,
                  color: theme.colorScheme.primary,
                ),
                textStyle: theme.textTheme.titleMedium.semiBold,
              ),
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: [
                  if (genres.isEmpty)
                    const Chip(label: Text('N/A'))
                  else
                    ...genres.map(
                      (genre) => Chip(
                        label: Text(
                          locale == AppLocale.ru ? genre.ru : genre.en,
                        ),
                      ),
                    ),
                ],
              ),
              // Authors Section
              IconWithText(
                text: t.titleInfo.authors,
                icon: Icon(
                  Icons.person_rounded,
                  size: 22,
                  color: theme.colorScheme.primary,
                ),
                textStyle: theme.textTheme.titleMedium.semiBold,
              ),
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: [
                  if (authors.isEmpty)
                    const Chip(label: Text('N/A'))
                  else
                    ...authors.map(
                      (author) => Chip(
                        label: Text(author),
                      ),
                    ),
                ],
              ),
              // Description Section
              IconWithText(
                text: t.titleInfo.description,
                icon: Icon(
                  Icons.description,
                  size: 22,
                  color: theme.colorScheme.primary,
                ),
                textStyle: theme.textTheme.titleMedium.semiBold,
              ),
              ReadMoreText(
                locale == AppLocale.ru ? description.ru ?? 'N/A' : description.en ?? 'N/A',
                colorClickableText: theme.colorScheme.primary,
                trimExpandedText: t.titleInfo.trimExpanded,
                trimCollapsedText: t.titleInfo.trimCollapsed,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
