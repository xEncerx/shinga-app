import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shinga/features/features.dart';
import 'package:shinga/i18n/strings.g.dart';
import 'package:ui_kit/ui_kit.dart';

/// Widget to display alternative names of a title.
class TitleDetailAltNames extends StatelessWidget {
  /// Creates a [TitleDetailAltNames] widget.
  const TitleDetailAltNames({super.key});

  @override
  Widget build(BuildContext context) {
    final t = Translations.of(context);

    return SaSectionCard.transparent(
      headerLabel: SaText(t.titleDetail.altNames),
      headerIcon: const SaIcon(icon: SaIconSource.huge(HugeIconsStrokeRounded.translate)),
      child: SelectionArea(
        child: BlocSelector<TitleDetailCubit, TitleDetailState, List<String>>(
          selector: (state) => state.data.title.altNames,
          builder: (_, altNames) {
            return SaReadMoreText(
              altNames.isNotEmpty ? altNames.join(' / ') : t.titleDetail.noAltNames,
              trimLines: 3,
              trimMode: TrimMode.line,
              style: AppTextStyle.bodyL,
              expandButtonLabel: t.titleDetail.common.readMoreText,
              collapseButtonLabel: t.titleDetail.common.hideText,
              showExpandableGradient: false,
            );
          },
        ),
      ),
    );
  }
}
