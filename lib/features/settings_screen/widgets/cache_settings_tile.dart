import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:animated_flip_counter/animated_flip_counter.dart';
import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:talker_flutter/talker_flutter.dart';
import 'package:visibility_detector/visibility_detector.dart';

import '../../../core/core.dart';
import '../../../domain/domain.dart';
import '../../../i18n/strings.g.dart';
import '../../../utils/show_snack_bar.dart';

/// A settings tile that displays cache size and allows users to clear the cache.
class CacheSettingsTile extends StatefulWidget {
  const CacheSettingsTile({super.key});

  @override
  State<CacheSettingsTile> createState() => _CacheSettingsTileState();
}

class _CacheSettingsTileState extends State<CacheSettingsTile> {
  final CacheService _cacheService = getIt<CacheService>();
  CacheSize _cacheSize = CacheSize(0, 'B');

  @override
  void initState() {
    super.initState();
    _loadCacheSize();
  }

  Future<void> _loadCacheSize() async {
    try {
      final size = await _cacheService.getCacheSize();
      if (mounted) {
        setState(() => _cacheSize = size);
      }
    } catch (e) {
      getIt<Talker>().error('Failed to load cache size', e);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = Translations.of(context);

    return ListTile(
      leading: const IconContainer(icon: HugeIcons.strokeRoundedDelete02),
      title: Text(
        t.settings.cache.title,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: VisibilityDetector(
        key: const ValueKey('cache_settings_tile'),
        onVisibilityChanged: (info) {
          // Update cache size when the widget becomes visible
          if (info.visibleFraction == 1) {
            _loadCacheSize();
          }
        },
        child: AnimatedFlipCounter(
          value: _cacheSize.size,
          fractionDigits: 2,
          suffix: _cacheSize.suffix,
          textStyle: Theme.of(context).textTheme.bodyMedium,
        ),
      ),
      onTap: _clearCache,
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
      await _loadCacheSize();
      if (mounted) {
        showSnackBar(context, t.settings.cache.cacheCleared);
      }
    }
  }
}
