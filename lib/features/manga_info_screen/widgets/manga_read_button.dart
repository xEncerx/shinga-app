import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/core.dart';
import '../../../cubit/cubit.dart';
import '../../../data/data.dart';
import '../../../i18n/strings.g.dart';
import '../../features.dart';

class MangaReadButton extends StatelessWidget {
  const MangaReadButton({
    super.key,
    required this.mangaData,
    required this.controller,
    required this.cubit,
  });

  final Manga mangaData;
  final TextEditingController controller;
  final MangaInfoCubit cubit;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      spacing: 5,
      children: [
        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            onPressed: () => _openUrl(context),
            onLongPress: () => _showChangeUrlAlertDialog(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.colorScheme.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: Text(
              t.titleInfo.readButton.title,
              style: theme.textTheme.titleLarge.semiBold.height(1).textColor(Colors.white),
            ),
          ),
        ),
        Center(
          child: Text(
            t.titleInfo.readButton.description,
            style: theme.textTheme.bodySmall.textColor(theme.hintColor),
          ),
        ),
      ],
    );
  }

  Future<void> _showChangeUrlAlertDialog(BuildContext context) async {
    final theme = Theme.of(context);

    return showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(t.titleInfo.readButton.changeUrl),
          content: TonalTextField(
            controller: controller,
            bgColor: theme.colorScheme.secondary,
            hintText: t.titleInfo.readButton.hintTextFieldTitle,
            rightContentPadding: 10,
            leftContentPadding: 10,
          ),
          actions: [
            TextButton(
              onPressed: () => _close(context),
              child: Text(t.common.cancel),
            ),
            BlocBuilder<MangaInfoCubit, MangaInfoState>(
              bloc: cubit,
              builder: (context, state) {
                return ElevatedButton(
                  onPressed: state is! MangaInfoLoading ? () => _saveUrl(context) : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.primary,
                  ),
                  child: Text(
                    t.common.save,
                    style: const TextStyle(
                      color: Colors.white,
                    ),
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _openUrl(BuildContext context) async {
    Uri url = Uri.parse(controller.text);

    if (url.host.isEmpty) {
      url = Uri.parse("${ApiConstants.googleUrl}/search?q=${mangaData.name}");
    }

    final bool useWebView = context.read<AppSettingsCubit>().state.appSettings.useWebView;

    // If current platform is not mobile, we use the external application
    // Or user set WebView to false in settings
    if (!AppTheme.isMobile || !useWebView) {
      if (!await launchUrl(
        url,
        mode: LaunchMode.externalApplication,
      )) {
        throw Exception('Could not launch $url');
      }
      return;
    }

    // If current platform is mobile, we use the WebView screen
    final Uri? newUrl = await context.router.push<Uri?>(
      ReadingWebViewRoute(initialUrl: url),
    );
    if (context.mounted && newUrl != null) {
      if (newUrl.toString() == controller.text) {
        // User didn't change the URL, so we don't need to update it
        return;
      }

      final result = await showDialog<String?>(
        context: context,
        builder: (context) => ReplaceUrlDialog(
          newUrl: newUrl.toString(),
        ),
      );

      if (result == null) {
        // User cancelled the dialog, so we don't need to update the URL
        return;
      }

      // Change user url to new
      controller.text = result;
      await cubit.updateMangaUrl(mangaData, result);
    }
  }

  Future<void> _saveUrl(BuildContext context) async {
    final String newUrl = controller.text.trim();

    if (newUrl.isEmpty) return;
    await cubit.updateMangaUrl(mangaData, newUrl);
    if (context.mounted) {
      _close(context);
    }
  }

  void _close(BuildContext context) => Navigator.of(context).pop();
}
