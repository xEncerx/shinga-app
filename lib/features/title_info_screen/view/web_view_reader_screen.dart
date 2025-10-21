import 'package:auto_route/auto_route.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../../core/core.dart';

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
  final GlobalKey webViewKey = GlobalKey();

  // WebView params
  InAppWebViewController? webViewController;
  PullToRefreshController? pullToRefreshController;
  InAppWebViewSettings settings = InAppWebViewSettings(isInspectable: kDebugMode);

  // Loading bar & navigation params
  double progress = 0;
  bool canGoBack = false;
  bool canGoForward = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    pullToRefreshController ??= PullToRefreshController(
      settings: PullToRefreshSettings(
        color: Theme.of(context).colorScheme.primary,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      ),
      onRefresh: () async {
        if (defaultTargetPlatform == TargetPlatform.android) {
          webViewController?.reload();
        } else if (defaultTargetPlatform == TargetPlatform.iOS) {
          webViewController?.loadUrl(
            urlRequest: URLRequest(url: await webViewController?.getUrl()),
          );
        }
      },
    );
  }

  @override
  void dispose() {
    webViewController?.dispose();
    webViewController = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        await _close(context);
      },
      child: Scaffold(
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
                color: canGoBack ? theme.colorScheme.primary : theme.hintColor,
                size: 20,
              ),
              onPressed: canGoBack ? () => webViewController?.goBack() : null,
            ),
            IconButton(
              icon: Icon(
                Icons.arrow_forward_ios_rounded,
                color: canGoForward ? theme.colorScheme.primary : theme.hintColor,
                size: 20,
              ),
              onPressed: canGoForward ? () => webViewController?.goForward() : null,
            ),
            IconButton(
              onPressed: () => webViewController?.loadUrl(
                urlRequest: URLRequest(url: WebUri(ApiConstants.googleUrl)),
              ),
              icon: HugeIcon(
                icon: HugeIcons.strokeRoundedInternet,
                color: theme.colorScheme.primary,
                size: 20,
              ),
            ),
          ],
        ),
        body: SafeArea(
          child: Stack(
            children: [
              InAppWebView(
                key: webViewKey,
                initialSettings: settings,
                initialUrlRequest: URLRequest(url: WebUri(widget.initialUrl.toString())),
                pullToRefreshController: pullToRefreshController,
                onWebViewCreated: (controller) => webViewController = controller,
                onLoadStop: (_, _) async => pullToRefreshController?.endRefreshing(),
                onReceivedError: (_, _, _) async => pullToRefreshController?.endRefreshing(),
                onProgressChanged: (controller, progress) async {
                  if (progress == 100) {
                    pullToRefreshController?.endRefreshing();
                  }
                  // Update navigation controls.
                  canGoBack = await webViewController?.canGoBack() ?? false;
                  canGoForward = await webViewController?.canGoForward() ?? false;
                  // Update loading bar.
                  this.progress = progress / 100;

                  if (mounted) setState(() {});
                },
              ),
              if (progress < 1.0)
                TweenAnimationBuilder<double>(
                  duration: const Duration(milliseconds: 250),
                  curve: Curves.easeInOut,
                  tween: Tween<double>(
                    begin: 0,
                    end: progress,
                  ),
                  builder: (context, value, _) => LinearProgressIndicator(
                    minHeight: 2,
                    backgroundColor: Colors.transparent,
                    value: value,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _close(BuildContext context) async {
    final WebUri? controllerUrl = await webViewController?.getUrl();
    final Uri currentUrl = Uri.parse(controllerUrl?.toString() ?? '');
    if (context.mounted) {
      context.pop<Uri>(currentUrl);
    }
  }
}
