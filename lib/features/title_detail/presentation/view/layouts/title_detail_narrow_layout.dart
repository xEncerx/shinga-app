import 'package:flutter/material.dart';
import 'package:shinga/features/features.dart';
import 'package:ui_kit/ui_kit.dart';

/// Layout widget for displaying title information on narrow screens.
class TitleDetailNarrowLayout extends StatelessWidget {
  /// Creates a [TitleDetailNarrowLayout] widget.
  const TitleDetailNarrowLayout({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Scaffold(
        floatingActionButton: SaFloatingActionButton(
          child: const SaIcon(
            icon: SaIconSource.material(Icons.menu_rounded),
          ),
          onPressed: () async => showTitleDetailMenuOverlay(context),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            child: Stack(
              children: [
                const SizedBox(
                  height: 200,
                  child: TitleDetailImmersiveCover(),
                ),
                const Positioned(
                  top: AppSpacing.s,
                  left: AppSpacing.s,
                  child: SaBackButton(),
                ),
                Container(
                  margin: const EdgeInsets.only(top: kToolbarHeight),
                  padding: const EdgeInsets.all(AppSpacing.m),
                  child: const Column(
                    spacing: AppSpacing.m,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Align(
                        alignment: Alignment.centerRight,
                        child: Column(
                          spacing: AppSpacing.s,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            TitleDetailLocalizableName(),
                            Row(
                              spacing: AppSpacing.s,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                TitleDetailRatingBadge(),
                                TitleDetailScoredByBadge(),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Row(
                        spacing: AppSpacing.m,
                        children: [
                          TitleDetailPreviewCover(),
                          Expanded(child: TitleDetailNarrowInfoSection()),
                        ],
                      ),
                      TitleDetailUserRatingDisplay(),
                      TitleDetailReadButton(),
                      TitleDetailGenres(),
                      TitleDetailCategories(),
                      TitleDetailAuthors(),
                      TitleDetailDescription(),
                      TitleDetailAdminInfoSection(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
