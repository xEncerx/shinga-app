import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shinga/core/core.dart';
import 'package:shinga/domain/domain.dart';
import 'package:shinga/features/features.dart';
import 'package:ui_kit/ui_kit.dart';

/// A widget that displays a selectable list of color schemes.
class ColorSchemeSelector extends StatelessWidget {
  /// Creates a [ColorSchemeSelector] widget.
  const ColorSchemeSelector({
    required this.currentScheme,
    super.key,
  });

  /// The currently selected color scheme.
  final AppColorScheme currentScheme;

  @override
  Widget build(BuildContext context) {
    return BlocSelector<AppSettingsCubit, AppSettingsState, AppThemeMode>(
      selector: (state) => state.settings.themeMode,
      builder: (_, themeMode) => Wrap(
        runSpacing: AppSpacing.s,
        spacing: AppSpacing.s,
        children: AppColorScheme.values.map((scheme) {
          final isSelected = scheme == currentScheme;
          final primaryColor = Theme.of(context).effectivePrimaryColor(scheme.toColorScheme());

          return GestureDetector(
            onTap: () => context.read<AppSettingsCubit>().changeColorScheme(scheme),
            child: SizedBox(
              width: 40,
              height: 40,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.all(AppSpacing.spaceUnit * 0.375),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(AppRadius.m),
                  border: Border.all(
                    color: isSelected ? primaryColor : Colors.transparent,
                    width: isSelected ? 2 : 0,
                  ),
                ),
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: primaryColor,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
