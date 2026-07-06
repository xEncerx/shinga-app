import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shinga/core/core.dart';
import 'package:shinga/domain/domain.dart';
import 'package:shinga/features/features.dart';
import 'package:shinga/i18n/i18n.dart';
import 'package:shinga/i18n/strings.g.dart';
import 'package:ui_kit/ui_kit.dart';

/// The main settings page displaying all settings options.
@RoutePage()
class SettingsMainPage extends StatelessWidget {
  /// Creates a [SettingsMainPage] widget.
  const SettingsMainPage({super.key});

  @override
  Widget build(BuildContext context) {
    final t = Translations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: SaText(t.settings.sectionName),
        actionsPadding: const EdgeInsets.only(right: AppSpacing.s),
        leading: BlocSelector<SessionBloc, SessionState, UserRole>(
          selector: (state) =>
              state is SessionAuthenticated ? state.session.user.role : UserRole.user,
          // Show logger button only for admin users
          builder: (_, userRole) {
            if (userRole == UserRole.admin) {
              return SaIconButton(
                icon: const SaIcon(icon: SaIconSource.huge(HugeIconsStrokeRounded.tvFix)),
                onPressed: () => context.router.push(const LoggerRoute()),
              );
            }
            return const SizedBox.shrink();
          },
        ),
        actions: [
          SaIconButton(
            icon: const SaIcon(icon: SaIconSource.huge(HugeIconsStrokeRounded.logout02)),
            onPressed: () async => showLogoutDialog(context),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.s),
          child: Column(
            spacing: AppSpacing.s,
            children: [
              BlocSelector<AppSettingsCubit, AppSettingsState, AppLanguage>(
                selector: (state) => state.settings.language,
                builder: (_, appLanguage) => SaEnumPickerTile<AppLanguage>(
                  value: appLanguage,
                  values: AppLanguage.values,
                  title: SaText(t.settings.language.title),
                  tileColor: Colors.transparent,
                  leading: const SaDecoratedIcon(
                    icon: SaIconSource.huge(HugeIconsStrokeRounded.languageSkill),
                  ),
                  dialogTitle: SaText(t.settings.language.title),
                  onChanged: (value) => context.read<AppSettingsCubit>().changeLanguage(value),
                  labelBuilder: (v) => v.i18n,
                ),
              ),
              SaListTile(
                title: SaText(t.settings.appearance.title),
                leading: const SaDecoratedIcon(
                  icon: SaIconSource.huge(HugeIconsStrokeRounded.paintBoard),
                ),
                trailing: const SaIcon(
                  icon: SaIconSource.huge(HugeIconsStrokeRounded.arrowRight01),
                ),
                tileColor: Colors.transparent,
                onTap: () => context.router.push(const SettingsAppearanceRoute()),
              ),
              SaListTile(
                title: SaText(t.settings.reader.title),
                leading: const SaDecoratedIcon(
                  icon: SaIconSource.huge(HugeIconsStrokeRounded.bookOpen02),
                ),
                trailing: const SaIcon(
                  icon: SaIconSource.huge(HugeIconsStrokeRounded.arrowRight01),
                ),
                tileColor: Colors.transparent,
                onTap: () => context.router.push(const SettingsReadingRoute()),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
