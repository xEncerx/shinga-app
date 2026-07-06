import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:shinga/features/features.dart';
import 'package:shinga/i18n/strings.g.dart';
import 'package:ui_kit/ui_kit.dart';

/// The settings page for appearance customization.
@RoutePage()
class SettingsAppearancePage extends StatelessWidget {
  /// Creates a [SettingsAppearancePage] widget.
  const SettingsAppearancePage({super.key});

  @override
  Widget build(BuildContext context) {
    final t = Translations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: SaText(t.settings.appearance.title),
        leading: const SaBackButton(),
      ),
      body: SafeArea(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 500),
          child: const SingleChildScrollView(
            padding: EdgeInsets.all(AppSpacing.s),
            child: Column(
              spacing: AppSpacing.m,
              children: [
                AppearanceThemePicker(),
                AppearanceTitleButtonStylePicker(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
