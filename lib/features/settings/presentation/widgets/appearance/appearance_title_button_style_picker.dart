import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shinga/domain/domain.dart';
import 'package:shinga/features/features.dart';
import 'package:shinga/i18n/strings.g.dart';
import 'package:ui_kit/ui_kit.dart';

/// A widget that allows selecting the title display style.
class AppearanceTitleButtonStylePicker extends StatelessWidget {
  /// Creates an [AppearanceTitleButtonStylePicker] widget.
  const AppearanceTitleButtonStylePicker({super.key});

  @override
  Widget build(BuildContext context) {
    final t = Translations.of(context);

    return SaSectionCard(
      headerLabel: SaText(t.settings.appearance.titleButtonStyle.title),
      headerIcon: const SaIcon(icon: SaIconSource.huge(HugeIconsStrokeRounded.gridView)),
      child: BlocSelector<AppSettingsCubit, AppSettingsState, TitleButtonStyle>(
        selector: (state) => state.settings.titleButtonStyle,
        builder: (context, titleButtonStyle) {
          return Row(
            spacing: AppSpacing.l,
            children: [
              _TitleButtonStyleOption(
                isSelected: titleButtonStyle == TitleButtonStyle.tile,
                onTap: () =>
                    context.read<AppSettingsCubit>().changeTitleButtonStyle(TitleButtonStyle.tile),
                child: const _ListPreview(),
              ),
              _TitleButtonStyleOption(
                isSelected: titleButtonStyle == TitleButtonStyle.card,
                onTap: () =>
                    context.read<AppSettingsCubit>().changeTitleButtonStyle(TitleButtonStyle.card),
                child: const _GridPreview(),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _TitleButtonStyleOption extends StatelessWidget {
  const _TitleButtonStyleOption({
    required this.isSelected,
    required this.onTap,
    required this.child,
  });

  final bool isSelected;
  final VoidCallback onTap;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 80,
        height: 110,
        padding: const EdgeInsets.all(AppSpacing.xs),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppRadius.card),
          border: Border.all(
            color: isSelected ? colors.primary : colors.outline,
            width: 2.5,
          ),
          color: isSelected
              ? colors.primary.withValues(alpha: 0.1)
              : colors.surfaceContainerHighest,
        ),
        child: Stack(
          children: [
            child,
            if (isSelected)
              Align(
                alignment: Alignment.bottomRight,
                child: SaIcon(
                  icon: const SaIconSource.huge(
                    HugeIconsStrokeRounded.checkmarkCircle02,
                    strokeWidth: 2.5,
                  ),
                  size: 18,
                  color: colors.primary,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _ListPreview extends StatelessWidget {
  const _ListPreview();

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      itemCount: 4,
      separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.s),
      padding: const EdgeInsets.all(AppSpacing.xs),
      itemBuilder: (_, _) => DecoratedBox(
        decoration: BoxDecoration(
          color: context.colors.onSurfaceVariant.withValues(alpha: 0.4),
          borderRadius: BorderRadius.circular(AppRadius.full),
        ),
        child: const SizedBox(height: 8),
      ),
    );
  }
}

class _GridPreview extends StatelessWidget {
  const _GridPreview();

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: AppSpacing.s,
      crossAxisSpacing: AppSpacing.s,
      padding: const EdgeInsets.all(AppSpacing.s).copyWith(top: AppSpacing.xs),
      childAspectRatio: 3 / 4,
      children: List.generate(
        4,
        (_) => DecoratedBox(
          decoration: BoxDecoration(
            color: context.colors.onSurfaceVariant.withValues(alpha: 0.4),
            borderRadius: BorderRadius.circular(AppRadius.s),
          ),
        ),
      ),
    );
  }
}
