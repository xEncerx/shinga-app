import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../../core/routes/app_router.dart';
import '../../../cubit/cubit.dart';
import '../../../data/data.dart';
import '../../../i18n/strings.g.dart';
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
                  onPressed: () async {
                    // TODO: Add confirmation dialog + normanl logout
                    context.router.replaceAll([const AuthRoute()]);
                    await GetIt.I<SecureStorageDatasource>().deleteToken();
                  },
                  child: Text(
                    t.settings.logout,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
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
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
