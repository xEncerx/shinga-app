import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';

import '../../../core/core.dart';
import '../../../i18n/strings.g.dart';

class AboutApplicationListTile extends StatelessWidget {
  const AboutApplicationListTile({super.key});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(t.settings.aboutApplication.title),
      leading: IconContainer(
        icon: Icons.app_shortcut_outlined,
        color: Theme.of(context).colorScheme.primary,
      ),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: () => context.router.navigatePath('/settings/about'),
    );
  }
}
