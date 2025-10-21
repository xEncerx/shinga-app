import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/core.dart';
import '../../../i18n/strings.g.dart';

@RoutePage()
class AboutApplicationScreen extends StatelessWidget {
  const AboutApplicationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(t.settings.aboutApplication.title),
        centerTitle: true,
      ),
      body: SafeArea(
        minimum: const EdgeInsets.all(15),
        child: ListView(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Open Source',
                  style: theme.textTheme.headlineMedium,
                ),
                const AppVersionBadge(),
              ],
            ),
            const SizedBox(height: 10),
            Text(t.settings.aboutApplication.openSourceDetail),
            const SizedBox(height: 10),
            Align(
              alignment: Alignment.centerLeft,
              child: OutlinedButton.icon(
                onPressed: _launchGithubURL,
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(80, 42),
                ),
                label: const HugeIcon(icon: HugeIcons.strokeRoundedGithub01),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _launchGithubURL() async {
    final url = Uri.parse(ApiConstants.githubRepoUrl);
    if (await canLaunchUrl(url)) {
      await launchUrl(
        url,
        mode: LaunchMode.externalApplication,
      );
    }
  }
}
