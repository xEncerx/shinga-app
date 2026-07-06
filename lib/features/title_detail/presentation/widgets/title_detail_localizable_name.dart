import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:shinga/features/features.dart';
import 'package:shinga/i18n/i18n.dart';
import 'package:shinga/i18n/strings.g.dart';
import 'package:ui_kit/ui_kit.dart';

/// Widget for displaying the title name. On tap, it opens a dialog with all the names.
class TitleDetailLocalizableName extends StatelessWidget {
  /// Creates a [TitleDetailLocalizableName] widget.
  const TitleDetailLocalizableName({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocSelector<
      TitleDetailCubit,
      TitleDetailState,
      (String, String?, String?, List<String>)
    >(
      selector: (state) => (
        state.data.title.name,
        state.data.title.nameRu,
        state.data.title.nameEn,
        state.data.title.altNames,
      ),
      builder: (context, names) {
        final (previewName, nameRu, nameEn, altNames) = names;

        return GestureDetector(
          onTap: () async => showMaterialModalBottomSheet<void>(
            context: context,
            builder: (context) => _buildNamesDialog(
              context,
              nameRu: nameRu,
              nameEn: nameEn,
              altNames: altNames,
            ),
          ),
          child: MouseRegion(
            cursor: SystemMouseCursors.click,
            child: Text.rich(
              TextSpan(
                children: [
                  const WidgetSpan(
                    alignment: PlaceholderAlignment.middle,
                    child: Padding(
                      padding: EdgeInsets.only(right: AppSpacing.s),
                      child: SaIcon(
                        icon: SaIconSource.huge(HugeIconsStrokeRounded.informationCircle),
                      ),
                    ),
                  ),
                  TextSpan(text: previewName),
                ],
              ),
              textAlign: TextAlign.right,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyle.titleL,
            ),
          ),
        );
      },
    );
  }

  Widget _buildNamesDialog(
    BuildContext context, {
    required String? nameRu,
    required String? nameEn,
    required List<String> altNames,
  }) {
    final t = Translations.of(context);

    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.l),
        child: SingleChildScrollView(
          child: Column(
            spacing: AppSpacing.xs,
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SaText('${t.titleDetail.nameRu}:', style: AppTextStyle.title),
              SelectionArea(
                child: SaText(
                  nameRu ?? 'N/A',
                  style: AppTextStyle.bodyL,
                ),
              ),
              const SaDivider(),
              SaText('${t.titleDetail.nameEn}:', style: AppTextStyle.title),
              SelectionArea(
                child: SaText(
                  nameEn ?? 'N/A',
                  style: AppTextStyle.bodyL,
                ),
              ),
              const SaDivider(),
              SaText('${t.titleDetail.altNames}:', style: AppTextStyle.title),
              SelectionArea(
                child: SaText(
                  altNames.isNotEmpty ? altNames.take(15).join('\n') : t.titleDetail.noAltNames,
                  style: AppTextStyle.bodyL,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
