import 'package:auto_route/auto_route.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shinga/core/core.dart';
import 'package:shinga/domain/domain.dart';
import 'package:shinga/features/features.dart';
import 'package:shinga/i18n/i18n.dart';
import 'package:shinga/i18n/strings.g.dart';
import 'package:ui_kit/ui_kit.dart';
import 'package:webview_guardian/webview_guardian.dart';

/// The settings page for reading preferences.
@RoutePage()
class SettingsReadingPage extends StatelessWidget {
  /// Creates a [SettingsReadingPage] widget.
  const SettingsReadingPage({super.key});

  @override
  Widget build(BuildContext context) {
    final t = Translations.of(context);

    /// Type need here to set the correct state of the cubit.
    // ignore: avoid_types_on_closure_parameters
    final readMode = context.select((AppSettingsCubit cubit) => cubit.state.settings.readMode);

    return Scaffold(
      appBar: AppBar(
        title: SaText(t.settings.reader.title),
        leading: const SaBackButton(),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.s),
          child: Column(
            spacing: AppSpacing.s,
            children: [
              SaEnumPickerTile<TitleReadMode>(
                values: TitleReadMode.values,
                value: readMode,
                title: SaText(t.settings.reader.readMode.title),
                dialogTitle: SaText(t.settings.reader.readMode.title),
                leading: const SaDecoratedIcon(
                  icon: SaIconSource.huge(HugeIconsStrokeRounded.browser),
                ),
                tileColor: Colors.transparent,
                labelBuilder: (value) => value.i18n,
                onChanged: (value) => context.read<AppSettingsCubit>().changeReadMode(value),
              ),
              if (readMode == TitleReadMode.webView &&
                  AdblockService.supportedPlatforms.contains(defaultTargetPlatform))
                SaListTile(
                  onTap: () => context.router.push(const SettingsAdBlockerRoute()),
                  title: SaText(t.settings.reader.adBlocker.title),
                  leading: const SaDecoratedIcon(
                    icon: SaIconSource.huge(HugeIconsStrokeRounded.userShield01),
                  ),
                  trailing: const SaIcon(
                    icon: SaIconSource.huge(HugeIconsStrokeRounded.arrowRight01),
                  ),
                  tileColor: Colors.transparent,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
