import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:talker/talker.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/core.dart';
import '../../../data/data.dart';
import '../../../i18n/strings.g.dart';
import '../../../utils/utils.dart';
import '../../features.dart';

class TitleReadButton extends StatelessWidget {
  const TitleReadButton({
    super.key,
    required this.titleData,
    required this.urlController,
  });

  final TitleWithUserData titleData;
  final TextEditingController urlController;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final userData = titleData.userData;

    return Column(
      spacing: 5,
      children: [
        FilledButton(
          onPressed: () => _openBrowser(context),
          onLongPress: () => userData != null
              ? _showChangeUrlDialog(context)
              : showSnackBar(
                  context,
                  t.titleInfo.errors.titleNotInBookmarks,
                ),
          style: FilledButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            minimumSize: const Size(double.infinity, 50),
          ),
          child: Text(
            t.titleInfo.readButton.title,
            style: theme.textTheme.titleLarge.semiBold
                .height(1)
                .withColor(theme.colorScheme.onPrimary),
          ),
        ),
        Center(
          child: Text(
            t.titleInfo.readButton.description,
            style: theme.textTheme.bodySmall.withColor(theme.hintColor),
          ),
        ),
      ],
    );
  }

  Future<void> _showChangeUrlDialog(BuildContext context) async {
    final result = await showTextInputDialog(
      context: context,
      title: t.titleInfo.readButton.changeUrl,
      okLabel: t.common.save,
      cancelLabel: t.common.cancel,
      isDestructiveAction: true,
      fullyCapitalizedForMaterial: false,
      textFields: [
        DialogTextField(
          initialText: urlController.text,
          hintText: t.titleInfo.readButton.hintTextFieldTitle,
        ),
      ],
    );
    if (result == null || result.isEmpty) return;

    // Save the new URL to the controller and bloc
    if (context.mounted && urlController.text != result[0]) {
      urlController.text = result[0];
      context.read<TitleInfoBloc>().add(
        UpdateTitleDataEvent(
          titleData: titleData,
          newUrl: urlController.text,
        ),
      );
    }
  }

  Future<void> _openBrowser(BuildContext context) async {
    Uri url = Uri.parse(urlController.text);

    if (url.host.isEmpty) {
      url = Uri.parse('${ApiConstants.googleUrl}/search?q=${titleData.title.nameEn}+manga');
    }

    final bool useWebView = context.read<SettingsCubit>().settings.useWebView;
    if (!AppTheme.isMobile || !useWebView) {
      if (!await launchUrl(
        url,
        mode: LaunchMode.externalApplication,
      )) {
        getIt<Talker>().error('Could not launch $url', StackTrace.current);
      }
      return;
    }

    final newUrl = await context.router.push<Uri?>(
      WebViewReaderRoute(initialUrl: url),
    );

    if (newUrl == null || newUrl == url || titleData.userData == null) return;

    if (context.mounted) {
      final chooseResult = await showTextInputDialog(
        context: context,
        title: t.titleInfo.replaceUrlDialog.title,
        message: t.titleInfo.replaceUrlDialog.description,
        okLabel: t.common.yes,
        cancelLabel: t.common.cancel,
        fullyCapitalizedForMaterial: false,
        isDestructiveAction: true,
        textFields: [
          DialogTextField(initialText: newUrl.toString()),
        ],
      );

      if (chooseResult == null || chooseResult.isEmpty) return;

      urlController.text = chooseResult[0];
      if (context.mounted) {
        context.read<TitleInfoBloc>().add(
          UpdateTitleDataEvent(
            titleData: titleData,
            newUrl: urlController.text,
          ),
        );
      }
    }
  }
}
