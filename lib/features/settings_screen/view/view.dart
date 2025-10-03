import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:talker_flutter/talker_flutter.dart';

import '../../../core/core.dart';
import '../../../data/data.dart';
import '../../../i18n/strings.g.dart';
import '../../features.dart';

@RoutePage()
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final t = Translations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(t.settings.title),
        centerTitle: true,
        leading: AppTheme.isDebug
            ? IconButton(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (context) => SafeArea(child: TalkerScreen(talker: getIt<Talker>())),
                  ),
                ),
                icon: const Icon(Icons.monitor_heart_outlined),
              )
            : null,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => _showLogoutDialog(context),
          ),
        ],
      ),
      body: SafeArea(
        child: BlocBuilder<SettingsCubit, SettingsState>(
          builder: (context, state) {
            return ListView(
              physics: const ClampingScrollPhysics(),
              children: [
                EnumSettingsTile(
                  title: t.settings.language,
                  prefixIcon: HugeIcons.strokeRoundedLanguageSkill,
                  currentValue: state.settings.language,
                  values: AppLocale.values,
                  onSelected: (AppLocale newLocale) async {
                    await context.read<SettingsCubit>().setLanguage(newLocale);
                  },
                ),
                EnumSettingsTile(
                  title: t.settings.theme,
                  prefixIcon: HugeIcons.strokeRoundedColors,
                  currentValue: state.settings.theme,
                  values: ThemeMode.values,
                  onSelected: (ThemeMode newTheme) {
                    context.read<SettingsCubit>().setTheme(newTheme);
                  },
                ),
                ColorSchemeSettingsTile(
                  title: t.settings.colorScheme,
                  prefixIcon: Icons.palette_outlined,
                  currentValue: state.settings.colorScheme,
                  values: FlexScheme.values,
                  onSelected: (FlexScheme newScheme) {
                    context.read<SettingsCubit>().setColorScheme(newScheme);
                  },
                ),
                SwitchSettingsTile(
                  title: t.settings.buttonStyle.title,
                  value: state.settings.isCardButtonStyle,
                  subTitle: state.settings.isCardButtonStyle
                      ? t.settings.buttonStyle.card
                      : t.settings.buttonStyle.tile,
                  prefixIcon: Icons.style_outlined,
                  onChanged: (value) {
                    context.read<SettingsCubit>().setCardButtonStyle(value);
                  },
                ),
                const CacheSettingsTile(),
                if (AppTheme.isMobile)
                  SwitchSettingsTile(
                    title: t.settings.webView.title,
                    subTitle: t.settings.webView.description,
                    value: state.settings.useWebView,
                    prefixIcon: Icons.web,
                    onChanged: (value) {
                      context.read<SettingsCubit>().setWebViewUsage(value);
                    },
                  ),
              ],
            );
          },
        ),
      ),
    );
  }

  Future<void> _showLogoutDialog(BuildContext context) async {
    final result = await showOkCancelAlertDialog(
      context: context,
      title: t.settings.logout.title,
      message: t.settings.logout.description,
      fullyCapitalizedForMaterial: false,
      isDestructiveAction: true,
      okLabel: t.common.yes,
      cancelLabel: t.common.no,
    );
    if (result == OkCancelResult.ok && context.mounted) {
      // Move to bloc
      context.router.replaceAll([const AuthRoute()]);
      await getIt<SecureStorageRepository>().deleteToken();
    }
  }
}
