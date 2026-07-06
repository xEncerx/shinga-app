import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shinga/core/core.dart';
import 'package:shinga/features/features.dart';
import 'package:shinga/i18n/i18n.dart';
import 'package:ui_kit/ui_kit.dart';

/// Layout widget for displaying title information on wide screens.
class TitleDetailWideLayout extends StatelessWidget {
  /// Creates a [TitleDetailWideLayout] widget.
  const TitleDetailWideLayout({super.key});

  @override
  Widget build(BuildContext context) {
    final leftColumnWidth = (MediaQuery.sizeOf(context).width / 3).clamp(200.0, 240.0);

    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            const SizedBox(
              height: 300,
              child: TitleDetailImmersiveCover(),
            ),
            SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.m).copyWith(top: kToolbarHeight),
              child: Row(
                spacing: AppSpacing.m,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: leftColumnWidth,
                    child: Column(
                      spacing: AppSpacing.m,
                      children: [
                        BlocSelector<TitleDetailCubit, TitleDetailState, String>(
                          selector: (state) => state.data.title.cover.original.toAbsoluteUrl(),
                          builder: (_, coverUrl) {
                            return TitleCover(coverUrl: coverUrl);
                          },
                        ),
                        const TitleDetailReadButton(),
                        const TitleDetailBookmarkDropdown(),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Column(
                      spacing: AppSpacing.m,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Flexible(
                              child: BlocSelector<TitleDetailCubit, TitleDetailState, String>(
                                selector: (state) => state.data.title.name,
                                builder: (_, titleName) {
                                  return SaText(
                                    titleName,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: AppTextStyle.h5,
                                  );
                                },
                              ),
                            ),
                            const TitleDetailRatingSection(),
                          ],
                        ),
                        const TitleDetailWideInfoSection(),
                        const TitleDetailAltNames(),
                        const TitleDetailGenres(),
                        const TitleDetailCategories(),
                        const TitleDetailAuthors(),
                        const TitleDetailDescription(),
                        const TitleDetailAdminInfoSection(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const Positioned(
              top: AppSpacing.s,
              left: AppSpacing.s,
              child: SaBackButton(),
            ),
          ],
        ),
      ),
    );
  }
}
