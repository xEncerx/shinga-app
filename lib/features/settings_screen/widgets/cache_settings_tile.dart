import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../../core/core.dart';
import '../../../domain/domain.dart';
import '../../../i18n/strings.g.dart';
import '../../../utils/show_snack_bar.dart';

class CacheSettingsTile extends StatefulWidget {
  const CacheSettingsTile({super.key});

  @override
  State<CacheSettingsTile> createState() => _CacheSettingsTileState();
}

class _CacheSettingsTileState extends State<CacheSettingsTile> {
  final CacheService _cacheService = getIt<CacheService>();

  @override
  Widget build(BuildContext context) {
    final t = Translations.of(context);

    return ListTile(
      leading: const Icon(
        HugeIcons.strokeRoundedDelete02,
        size: 24,
      ),
      title: Text(
        t.settings.cache.title,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        t.settings.cache.longPress,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: FutureBuilder(
        future: _cacheService.getCacheSize(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const CircularProgressIndicator();
          } else if (snapshot.hasError) {
            return const Icon(Icons.error);
          } else {
            return Text(
              snapshot.data ?? '0 B',
              style: Theme.of(context).textTheme.bodyMedium,
            );
          }
        },
      ),
      onTap: _clearCache,
      onLongPress: () => setState(() {}),
    );
  }

  Future<void> _clearCache() async {
    final result = await showOkCancelAlertDialog(
      context: context,
      title: t.settings.cache.clearTitle,
      message: t.settings.cache.clearDescription,
      fullyCapitalizedForMaterial: false,
      isDestructiveAction: true,
      okLabel: t.common.yes,
      cancelLabel: t.common.no,
    );

    if (result == OkCancelResult.ok) {
      await _cacheService.clearCache();
      setState(() {});
      if (mounted) {
        showSnackBar(context, t.settings.cache.cacheCleared);
      }
    }
  }
}
