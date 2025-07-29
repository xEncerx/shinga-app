import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../../core/constants/api_constants.dart';

@RoutePage()
class WebViewReaderScreen extends StatefulWidget {
  const WebViewReaderScreen({
    super.key,
    required this.initialUrl,
  });

  final Uri initialUrl;

  @override
  State<WebViewReaderScreen> createState() => _WebViewReaderScreenState();
}

class _WebViewReaderScreenState extends State<WebViewReaderScreen> {
  late final WebViewController webViewController;
  final cookieManager = WebViewCookieManager();

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    webViewController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (_) => setState(() => isLoading = true),
          onPageFinished: (_) => setState(() => isLoading = false),
        ),
      )
      ..loadRequest(widget.initialUrl);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: IconButton(
          onPressed: () async => _close(context),
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: theme.colorScheme.primary,
            size: 20,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.arrow_back_ios_new_rounded,
              color: theme.colorScheme.primary,
              size: 20,
            ),
            onPressed: () => webViewController.goBack(),
          ),
          IconButton(
            icon: Icon(
              Icons.arrow_forward_ios_rounded,
              color: theme.colorScheme.primary,
              size: 20,
            ),
            onPressed: () => webViewController.goForward(),
          ),
          IconButton(
            onPressed: () => webViewController.reload(),
            icon: Icon(
              Icons.refresh_rounded,
              color: theme.colorScheme.primary,
            ),
          ),
          IconButton(
            onPressed: () => webViewController.loadRequest(
              Uri.parse(ApiConstants.googleUrl),
            ),
            icon: Icon(
              HugeIcons.strokeRoundedInternet,
              color: theme.colorScheme.primary,
              size: 20,
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            if (isLoading)
              LinearProgressIndicator(
                minHeight: 2,
                backgroundColor: Colors.transparent,
                valueColor: AlwaysStoppedAnimation<Color>(
                  theme.colorScheme.primary,
                ),
              ),
            Expanded(
              child: WebViewWidget(
                controller: webViewController,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _close(BuildContext context) async {
    final String? controllerUrl = await webViewController.currentUrl();
    final Uri currentUrl = Uri.parse(controllerUrl ?? '');
    if (context.mounted) {
      context.maybePop<Uri>(currentUrl);
    }
  }
}
