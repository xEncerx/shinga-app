import 'package:flutter/material.dart';

import '../../../core/core.dart';

class TitleInfoPreviewCover extends StatelessWidget {
  const TitleInfoPreviewCover({
    super.key,
    required this.coverUrl,
  });

  final String coverUrl;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Stack(
        alignment: Alignment.center,
        children: [
          Opacity(
            opacity: 0.3,
            child: TitleCover(
              width: double.infinity,
              coverUrl: coverUrl,
            ),
          ),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  theme.scaffoldBackgroundColor,
                  theme.scaffoldBackgroundColor.withValues(alpha: 0.4),
                  theme.scaffoldBackgroundColor,
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: TitleCover(
              width: 250,
              height: 360,
              coverUrl: coverUrl,
            ),
          ),
        ],
      ),
    );
  }
}
