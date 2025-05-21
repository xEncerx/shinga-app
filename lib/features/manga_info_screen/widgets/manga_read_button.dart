import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/core.dart';
import '../../../i18n/strings.g.dart';
import '../../features.dart';

class MangaReadButton extends StatelessWidget {
  const MangaReadButton({
    super.key,
    required this.mangaId,
    required this.controller,
    required this.cubit,
  });

  final String mangaId;
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
            onPressed: _openUrl,
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
              style: theme.textTheme.titleLarge.semiBold.textColor(Colors.white),
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

  Future<void> _openUrl() async {
    if (controller.text.isEmpty) return;

    final Uri url = Uri.parse(controller.text);
    if (!await launchUrl(url)) {
      throw Exception('Could not launch $url');
    }
  }

  Future<void> _saveUrl(BuildContext context) async {
    final String newUrl = controller.text.trim();

    if (newUrl.isEmpty) return;
    await cubit.updateMangaUrl(mangaId, newUrl);
    if (context.mounted) {
      _close(context);
    }
  }

  void _close(BuildContext context) => Navigator.of(context).pop();
}
