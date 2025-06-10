import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../../core/core.dart';
import 'widgets.dart';

class ReadingAppBar extends StatelessWidget implements PreferredSizeWidget {
  const ReadingAppBar({
    super.key,
    required this.webViewController,
    required this.cookieManager,
  });

  final WebViewController webViewController;
  final WebViewCookieManager cookieManager;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AppBar(
      automaticallyImplyLeading: false,
      leading: IconButton(
        onPressed: () async => _close(context),
        icon: Icon(
          Icons.close_rounded,
          color: theme.colorScheme.primary,
        ),
      ),
      title: Text(
        "Shinga",
        style: theme.textTheme.headlineMedium.ellipsis,
      ),
      centerTitle: true,
      actions: [
        IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: theme.colorScheme.primary,
          ),
          iconSize: 20,
          onPressed: () async {
            await webViewController.goBack();
          },
        ),
        IconButton(
          icon: Icon(
            Icons.arrow_forward_ios_rounded,
            color: theme.colorScheme.primary,
          ),
          iconSize: 20,
          onPressed: () async {
            await webViewController.goForward();
          },
        ),
        OptionsWebViewMenu(
          webViewController: webViewController,
          cookieManager: cookieManager,
        ),
      ],
      actionsPadding: const EdgeInsets.symmetric(horizontal: 5),
    );
  }

  Future<void> _close(BuildContext context) async {
    final String? controllerUrl = await webViewController.currentUrl();
    final Uri currentUrl = Uri.parse(controllerUrl ?? '');
    if (context.mounted) {
      context.maybePop<Uri>(currentUrl);
    }
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
