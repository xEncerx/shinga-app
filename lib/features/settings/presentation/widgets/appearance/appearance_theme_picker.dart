import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shinga/domain/domain.dart';
import 'package:shinga/features/features.dart';
import 'package:shinga/i18n/strings.g.dart';
import 'package:ui_kit/ui_kit.dart';

/// A widget that allows selecting the application theme and color scheme.
class AppearanceThemePicker extends StatefulWidget {
  /// Creates an [AppearanceThemePicker] widget.
  const AppearanceThemePicker({super.key});

  @override
  State<AppearanceThemePicker> createState() => _AppearanceThemePickerState();
}

class _AppearanceThemePickerState extends State<AppearanceThemePicker> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final t = Translations.of(context);

    return SaSectionCard(
      headerLabel: SaText(t.settings.appearance.themeTitle),
      headerIcon: const SaIcon(icon: SaIconSource.huge(HugeIconsStrokeRounded.paintBoard)),
      child: BlocSelector<AppSettingsCubit, AppSettingsState, (AppThemeMode, AppColorScheme)>(
        selector: (state) => (state.settings.themeMode, state.settings.colorScheme),
        builder: (_, themeData) => Column(
          spacing: AppSpacing.s,
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SaCardSelector<AppThemeMode>(
              items: [
                SaCardSelectorItem(
                  value: AppThemeMode.light,
                  icon: const SaIconSource.material(Icons.sunny),
                  label: t.settings.appearance.themeMode.values.light,
                ),
                SaCardSelectorItem(
                  value: AppThemeMode.dark,
                  icon: const SaIconSource.material(Icons.nights_stay_rounded),
                  label: t.settings.appearance.themeMode.values.dark,
                ),
                SaCardSelectorItem(
                  value: AppThemeMode.system,
                  icon: const SaIconSource.material(Icons.brightness_auto_rounded),
                  label: t.settings.appearance.themeMode.values.system,
                ),
              ],
              selected: themeData.$1,
              onChanged: (newSelection) async {
                await context.read<AppSettingsCubit>().changeThemeMode(newSelection);
              },
            ),
            SaListTile(
              title: SaText(t.settings.appearance.colorScheme.title),
              trailing: Row(
                spacing: AppSpacing.s,
                children: [
                  SizedBox.square(
                    dimension: 24,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: context.colors.primary,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                  AnimatedRotation(
                    turns: _isExpanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 300),
                    child: const SaIcon(
                      icon: SaIconSource.huge(HugeIconsStrokeRounded.arrowDown01),
                    ),
                  ),
                ],
              ),
              tileColor: Colors.transparent,
              onTap: () => setState(() => _isExpanded = !_isExpanded),
            ),
            SaAnimatedClipRect(
              open: _isExpanded,
              alignment: Alignment.topCenter,
              child: ColorSchemeSelector(currentScheme: themeData.$2),
            ),
          ],
        ),
      ),
    );
  }
}
