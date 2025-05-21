import 'package:auto_route/auto_route.dart';
import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../../core/core.dart';
import '../../../cubit/cubit.dart';
import '../../../data/data.dart';
import '../../../i18n/strings.g.dart';
import '../../favorite_screen/bloc/favorite_bloc.dart';
import '../widgets/widgets.dart';

@RoutePage()
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(t.settings.title),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Stack(
          children: [
            Container(
              alignment: Alignment.bottomCenter,
              margin: const EdgeInsets.all(10),
              child: SizedBox(
                height: 50,
                width: double.infinity,
                child: FilledButton.tonal(
                  onPressed: () async => _showLogoutDialog(context),
                  child: Text(
                    t.settings.logout.title,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleLarge.semiBold,
                  ),
                ),
              ),
            ),
            BlocBuilder<AppSettingsCubit, AppSettingsState>(
              builder: (context, state) {
                return Column(
                  children: [
                    SwitchSettingsTile(
                      title: t.settings.theme.title,
                      value: state.appSettings.isDarkTheme,
                      subTitle: state.appSettings.isDarkTheme
                          ? t.settings.theme.darkMode
                          : t.settings.theme.lightMode,
                      leadingIcon: HugeIcons.strokeRoundedColors,
                      onChanged: (v) async {
                        await context.read<AppSettingsCubit>().setDarkTheme(v);
                      },
                    ),
                    SwitchSettingsTile(
                      title: t.settings.mangaButtonStyle.title,
                      value: state.appSettings.isCardButtonStyle,
                      subTitle: state.appSettings.isCardButtonStyle
                          ? t.settings.mangaButtonStyle.cardButtonStyle
                          : t.settings.mangaButtonStyle.tileButtonStyle,
                      leadingIcon: Icons.style_outlined,
                      onChanged: (v) async {
                        await context.read<AppSettingsCubit>().setCardButtonStyle(v);
                      },
                    ),
                    SwitchSettingsTile(
                      title: t.settings.language.title,
                      value: state.appSettings.languageCode == 'en',
                      subTitle: state.appSettings.languageCode == 'en'
                          ? t.settings.language.enLanguage
                          : t.settings.language.ruLanguage,
                      leadingIcon: HugeIcons.strokeRoundedLanguageSkill,
                      onChanged: (v) async {
                        await context.read<AppSettingsCubit>().setLanguageCode(
                              v ? 'en' : 'ru',
                            );
                      },
                    ),
                    DropdownSettingsTile<MangaSource>(
                      title: t.settings.suggestProvider,
                      leadingIcon: Icons.search,
                      value: state.appSettings.suggestProvider,
                      items: MangaSource.suggestProviders,
                      itemLabelBuilder: (provider) => provider.name.capitalize,
                      onChanged: (provider) async {
                        if (provider != null) {
                          await context.read<AppSettingsCubit>().setSuggestProvider(provider);
                        }
                      },
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showLogoutDialog(BuildContext context) async {
    final result = await showAdaptiveDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(t.settings.logout.title),
        content: Text(t.settings.logout.description),
        actions: [
          FilledButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(t.common.cancel),
          ),
          FilledButton.tonal(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(t.common.yes),
          ),
        ],
      ),
    );
    if (result != null && result && context.mounted) {
      context.router.replaceAll([const AuthRoute()]);
      // ! Bug: its make request when user logout
      context.read<FavoriteBloc>().add(ClearFavoriteState());
      await GetIt.I<SecureStorageDatasource>().deleteToken();
    }
  }
}
