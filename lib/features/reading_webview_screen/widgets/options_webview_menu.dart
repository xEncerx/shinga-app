import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../../core/core.dart';
import '../../../i18n/strings.g.dart';

class OptionsWebViewMenu extends StatelessWidget {
  const OptionsWebViewMenu({
    super.key,
    required this.webViewController,
    required this.cookieManager,
  });

  final WebViewController webViewController;
  final WebViewCookieManager cookieManager;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return PopupMenuButton<WebViewOptions>(
      icon: Icon(
        Icons.keyboard_arrow_down_rounded,
        size: 32,
        color: theme.colorScheme.primary,
      ),
      onSelected: (value) async {
        switch (value) {
          case WebViewOptions.yandexProvider:
            await webViewController.loadRequest(
              Uri.parse(ApiConstants.yandexUrl),
            );
          case WebViewOptions.googleProvider:
            await webViewController.loadRequest(
              Uri.parse(ApiConstants.googleUrl),
            );
          case WebViewOptions.clearCookies:
            await cookieManager.clearCookies();
          case WebViewOptions.reload:
            await webViewController.reload();
        }
      },
      itemBuilder: (BuildContext context) => [
        PopupMenuItem<WebViewOptions>(
          value: WebViewOptions.yandexProvider,
          child: Text(t.webViewScreen.openYandex),
        ),
        PopupMenuItem<WebViewOptions>(
          value: WebViewOptions.googleProvider,
          child: Text(t.webViewScreen.openGoogle),
        ),
        PopupMenuItem<WebViewOptions>(
          value: WebViewOptions.clearCookies,
          child: Text(t.webViewScreen.clearCookies),
        ),
        PopupMenuItem<WebViewOptions>(
          value: WebViewOptions.reload,
          child: Text(t.webViewScreen.reloadPage),
        ),
      ],
    );
  }
}
