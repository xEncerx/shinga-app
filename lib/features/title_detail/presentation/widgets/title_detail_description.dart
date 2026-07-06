import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shinga/features/features.dart';
import 'package:shinga/i18n/i18n.dart';
import 'package:shinga/i18n/strings.g.dart';
import 'package:ui_kit/ui_kit.dart';

/// Widget for displaying the description of a title in the title detail view.
class TitleDetailDescription extends StatelessWidget {
  /// Creates a [TitleDetailDescription] widget.
  const TitleDetailDescription({super.key});

  @override
  Widget build(BuildContext context) {
    final t = Translations.of(context);

    return SaSectionCard.transparent(
      headerLabel: SaText(t.titleDetail.description.title),
      headerIcon: const SaIcon(icon: SaIconSource.huge(HugeIconsStrokeRounded.note)),
      child: BlocSelector<TitleDetailCubit, TitleDetailState, String>(
        selector: (state) => state.data.title.description,
        builder: (_, description) => SaReadMoreText(
          description,
          trimLines: 5,
          trimMode: TrimMode.line,
          style: AppTextStyle.bodyL,
          expandButtonLabel: t.titleDetail.common.readMoreText,
          collapseButtonLabel: t.titleDetail.common.hideText,
        ),
      ),
    );
  }
}
