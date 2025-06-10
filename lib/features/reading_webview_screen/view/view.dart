import 'package:auto_route/annotations.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../features.dart';

@RoutePage()
class ReadingWebViewScreen extends StatefulWidget {
  const ReadingWebViewScreen({
    super.key,
    required this.initialUrl,
  });

  final Uri initialUrl;

  @override
  State<ReadingWebViewScreen> createState() => _ReadingWebViewScreenState();
}

class _ReadingWebViewScreenState extends State<ReadingWebViewScreen> {
  late final WebViewController controller;
  final cookieManager = WebViewCookieManager();
  bool isLoading = true;

  @override
  void initState() {
    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (url) {
            setState(() => isLoading = true);
          },
          onPageFinished: (url) {
            setState(() => isLoading = false);
          },
        ),
      )
      ..loadRequest(widget.initialUrl);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // final theme = Theme.of(context);

    return Scaffold(
      appBar: ReadingAppBar(
        webViewController: controller,
        cookieManager: cookieManager,
      ),
      body: Column(
        children: [
          if (isLoading)
            const LinearProgressIndicator(
              minHeight: 2,
              backgroundColor: Colors.transparent,
              valueColor: AlwaysStoppedAnimation<Color>(
                Colors.blue,
              ),
            ),
          Expanded(
            child: WebViewWidget(
              controller: controller,
            ),
          ),
        ],
      ),
    );
  }
}
