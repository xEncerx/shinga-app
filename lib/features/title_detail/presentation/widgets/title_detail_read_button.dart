import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shinga/core/core.dart';
import 'package:shinga/domain/domain.dart';
import 'package:shinga/features/features.dart';
import 'package:shinga/i18n/i18n.dart';
import 'package:shinga/i18n/strings.g.dart';
import 'package:ui_kit/ui_kit.dart';
import 'package:url_launcher/url_launcher.dart';

/// A button widget that allows the user to read the title.
class TitleDetailReadButton extends StatefulWidget {
  /// Creates a [TitleDetailReadButton] instance.
  const TitleDetailReadButton({super.key});

  @override
  State<TitleDetailReadButton> createState() => _TitleDetailReadButtonState();
}

class _TitleDetailReadButtonState extends State<TitleDetailReadButton> {
  String _currentSavedUrl = '';

  @override
  Widget build(BuildContext context) {
    final t = Translations.of(context);

    return BlocSelector<TitleDetailCubit, TitleDetailState, (String, bool, bool)>(
      selector: (state) => (
        state.data.userData?.currentUrl ?? '',
        state.hasUserData,
        state.isFieldLoading(TitleDetailField.currentUrl),
      ),
      builder: (_, readData) {
        final (currentUrl, hasUserData, isCurrentUrlLoading) = readData;
        _currentSavedUrl = currentUrl;

        return Column(
          spacing: AppSpacing.xs,
          children: [
            SaPrimaryButton.icon(
              width: double.infinity,
              label: SaText(t.titleDetail.readButton.readTitle),
              icon: const SaIcon(icon: SaIconSource.huge(HugeIconsStrokeRounded.bookOpen02)),
              isLoading: isCurrentUrlLoading,
              onPressed: _openReader,
              onLongPress: hasUserData ? _openEditLinkDialog : null,
            ),
            if (hasUserData)
              SaText(
                t.titleDetail.readButton.longPressAction,
                textAlign: TextAlign.center,
                style: AppTextStyle.captionS.copyWith(color: context.colors.onSurfaceVariant),
              ),
          ],
        );
      },
    );
  }

  Future<void> _openReader() async {
    final titleData = context.read<TitleDetailCubit>().state.data;

    final initialUrl = _currentSavedUrl.isNotEmpty
        ? _currentSavedUrl
        : buildGoogleSearchUrl(titleData.title.name);

    final readMode = context.read<AppSettingsCubit>().state.settings.readMode;
    return switch (readMode) {
      TitleReadMode.externalBrowser => _openExternalBrowser(initialUrl),
      TitleReadMode.webView => _openWebView(initialUrl),
    };
  }

  Future<void> _openExternalBrowser(String initialUrl) async {
    await launchUrl(Uri.parse(initialUrl), mode: LaunchMode.externalApplication);
  }

  Future<void> _openWebView(String initialUrl) async {
    final newUrl = await context.router.push<String>(
      WebviewReaderRoute(initialUrl: initialUrl),
    );
    if (!mounted) return;

    if (newUrl != null && newUrl.isNotEmpty && newUrl != initialUrl) {
      final t = Translations.of(context);
      final cubit = context.read<TitleDetailCubit>();

      await showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (context) => SaTextFieldDialog(
          initialText: newUrl,
          title: t.titleDetail.saveProgressDialog.title,
          description: t.titleDetail.saveProgressDialog.description,
          confirmText: t.common.save,
          cancelText: t.common.cancel,
          icon: const SaIconSource.huge(HugeIconsStrokeRounded.bookmark02),
          onConfirm: cubit.changeCurrentUrl,
          textFieldBuilder: (context, controller) => SaTextField(
            controller: controller,
            hintText: t.titleDetail.saveProgressDialog.hint,
          ),
        ),
      );
    }
  }

  Future<void> _openEditLinkDialog() async {
    final t = Translations.of(context);

    await showDialog<void>(
      context: context,
      builder: (_) => SaTextFieldDialog(
        title: t.titleDetail.editUrlDialog.title,
        description: t.titleDetail.editUrlDialog.description,
        confirmText: t.common.save,
        cancelText: t.common.cancel,
        icon: const SaIconSource.huge(HugeIconsStrokeRounded.link01),
        initialText: _currentSavedUrl,
        onConfirm: (newUrl) async => context.read<TitleDetailCubit>().changeCurrentUrl(newUrl),
        textFieldBuilder: (context, controller) => SaTextField(
          controller: controller,
          autofocus: true,
          hintText: t.titleDetail.editUrlDialog.hint,
        ),
      ),
    );
  }
}
