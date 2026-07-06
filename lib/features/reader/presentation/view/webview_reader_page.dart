import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shinga/core/core.dart';
import 'package:shinga/features/features.dart';
import 'package:ui_kit/ui_kit.dart';
import 'package:webview_guardian/webview_guardian.dart';

/// The page that displays the manga/novel using a WebView.
@RoutePage()
class WebviewReaderPage extends StatefulWidget {
  /// Creates a [WebviewReaderPage].
  const WebviewReaderPage({
    required this.initialUrl,
    super.key,
  });

  /// The initial URL to load.
  final String initialUrl;

  @override
  State<WebviewReaderPage> createState() => _WebviewReaderPageState();
}

class _WebviewReaderPageState extends State<WebviewReaderPage> {
  WebViewController? _controller;
  late final TextEditingController _urlController;

  final _isLoadingNotifier = ValueNotifier<bool>(true);
  final _canGoBackNotifier = ValueNotifier<bool>(false);
  final _canGoForwardNotifier = ValueNotifier<bool>(false);
  double _progress = 0;

  @override
  void initState() {
    super.initState();
    _urlController = TextEditingController(text: widget.initialUrl);

    unawaited(
      SystemChrome.setEnabledSystemUIMode(
        SystemUiMode.manual,
        overlays: [SystemUiOverlay.top],
      ),
    );
  }

  @override
  void dispose() {
    _urlController.dispose();
    _isLoadingNotifier.dispose();
    _canGoBackNotifier.dispose();
    _canGoForwardNotifier.dispose();
    unawaited(
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge),
    );
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        if (await _controller?.canGoBack() ?? false) {
          await _controller?.goBack();
        } else if (context.mounted) {
          _close(context);
        }
      },
      child: Scaffold(
        appBar: WebViewNavigationBar(
          urlController: _urlController,
          webViewController: _controller,
          isLoadingNotifier: _isLoadingNotifier,
          canGoBackNotifier: _canGoBackNotifier,
          canGoForwardNotifier: _canGoForwardNotifier,
          onClose: () => _close(context),
        ),
        body: Column(
          children: [
            ValueListenableBuilder<bool>(
              valueListenable: _isLoadingNotifier,
              builder: (_, isLoading, _) {
                if (isLoading) {
                  return SaProgressIndicator(
                    value: _progress,
                    height: 2,
                    shouldAnimateValue: true,
                  );
                }
                return const SizedBox(height: 2); // Placeholder to maintain layout stability
              },
            ),
            Expanded(
              child: WebView(
                initialUrl: widget.initialUrl,
                adblockService: context.deps.adBlocker,
                enablePullToRefresh: true,
                onLoadStart: (url) {
                  _isLoadingNotifier.value = true;
                  setState(() {
                    _urlController.text = url?.toString() ?? '';
                  });
                },
                onLoadStop: (url) async {
                  _isLoadingNotifier.value = false;
                  await _handleNavigation(url);
                },
                onUpdateVisitedHistory: (url, _) => _handleNavigation(url),
                onProgressChanged: (progress) => setState(() => _progress = progress / 100),
                onWebViewCreated: (controller) => _controller = controller,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _close(BuildContext context) => context.router.pop(_urlController.text);

  Future<void> _handleNavigation(Uri? uri) async {
    if (uri == null) return;

    final url = uri.toString();
    if (_urlController.text != url) {
      _urlController.text = url;
    }

    final canGoBack = await _controller?.canGoBack() ?? false;
    final canGoForward = await _controller?.canGoForward() ?? false;

    if (_canGoBackNotifier.value != canGoBack) {
      _canGoBackNotifier.value = canGoBack;
    }
    if (_canGoForwardNotifier.value != canGoForward) {
      _canGoForwardNotifier.value = canGoForward;
    }
  }
}
