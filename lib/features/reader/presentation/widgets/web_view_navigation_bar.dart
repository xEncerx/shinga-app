import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'package:shinga/features/features.dart';
import 'package:shinga/i18n/strings.g.dart';
import 'package:ui_kit/ui_kit.dart';
import 'package:webview_guardian/webview_guardian.dart';

class WebViewNavigationBar extends StatefulWidget implements PreferredSizeWidget {
  const WebViewNavigationBar({
    required this.urlController,
    required this.webViewController,
    required this.isLoadingNotifier,
    required this.canGoBackNotifier,
    required this.canGoForwardNotifier,
    required this.onClose,
    super.key,
  });

  final TextEditingController urlController;
  final WebViewController? webViewController;
  final ValueNotifier<bool> isLoadingNotifier;
  final ValueNotifier<bool> canGoBackNotifier;
  final ValueNotifier<bool> canGoForwardNotifier;
  final VoidCallback? onClose;

  @override
  Size get preferredSize => const Size.fromHeight(kMinInteractiveDimension);

  @override
  State<WebViewNavigationBar> createState() => _WebViewNavigationBarState();
}

class _WebViewNavigationBarState extends State<WebViewNavigationBar> {
  @override
  Widget build(BuildContext context) {
    final t = Translations.of(context);
    final colorScheme = context.colors;
    final isWide = ResponsiveBreakpoints.of(context).largerThan(MOBILE);

    return AppBar(
      automaticallyImplyLeading: false,
      title: Row(
        spacing: AppSpacing.s,
        children: [
          SaIconButton(
            icon: const SaIcon(icon: SaIconSource.material(Icons.close_rounded)),
            onPressed: widget.onClose,
          ),
          Expanded(
            child: ValueListenableBuilder<bool>(
              valueListenable: widget.isLoadingNotifier,
              builder: (_, isLoading, _) {
                return SaTextField(
                  controller: widget.urlController,
                  hintText: t.reader.webview.hintSearchText,
                  onSubmitted: _handleUrlSubmit,
                  keyboardType: TextInputType.url,
                  textInputAction: TextInputAction.go,
                  suffixIcon: !isLoading
                      ? SaIconButton(
                          icon: SaIcon(
                            icon: const SaIconSource.material(Icons.refresh),
                            color: colorScheme.onSurfaceVariant,
                          ),
                          onPressed: () async => widget.webViewController?.reload(),
                          // Stop loading
                        )
                      : SaIconButton(
                          icon: SaIcon(
                            icon: const SaIconSource.material(Icons.close),
                            color: colorScheme.onSurfaceVariant,
                          ),
                          onPressed: () async {
                            await widget.webViewController?.stopLoading();
                            widget.isLoadingNotifier.value = false;
                          },
                        ),
                );
              },
            ),
          ),
        ],
      ),
      actionsPadding: const EdgeInsets.only(right: AppSpacing.m),
      actions: [
        if (isWide) _buildNavigationMenu(),
        PopupMenuButton<String>(
          icon: const SaIcon(icon: SaIconSource.material(Icons.more_vert)),
          tooltip: '',
          color: colorScheme.surface,
          offset: const Offset(0, kMinInteractiveDimension),
          onSelected: (value) async {
            switch (value) {
              case 'home':
                await _handleUrlSubmit('https://www.google.com');
              case 'adblock':
                await context.router.pushPath('/adblocker-settings');
            }
          },
          itemBuilder: (context) => [
            if (!isWide) ...[
              PopupMenuItem(enabled: false, child: _buildNavigationMenu(true)),
              const PopupMenuDivider(),
            ],
            PopupMenuItem(
              value: 'home',
              child: Center(child: SaText(t.reader.webview.openHomeBrowser)),
            ),
            PopupMenuItem(
              value: 'adblock',
              child: Center(child: SaText(t.reader.webview.adBlockerSettings)),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildNavigationMenu([bool needPopMenu = false]) {
    return ListenableBuilder(
      listenable: Listenable.merge([widget.canGoBackNotifier, widget.canGoForwardNotifier]),
      builder: (_, _) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SaIconButton(
              icon: const SaIcon(icon: SaIconSource.material(Icons.arrow_back_ios_rounded)),
              onPressed: widget.canGoBackNotifier.value
                  ? () async {
                      if (needPopMenu) {
                        context.router.pop();
                      }
                      await widget.webViewController?.goBack();
                    }
                  : null,
            ),
            const SizedBox(width: AppSpacing.m),
            SaIconButton(
              icon: const SaIcon(icon: SaIconSource.material(Icons.arrow_forward_ios_rounded)),
              onPressed: widget.canGoForwardNotifier.value
                  ? () async {
                      if (needPopMenu) {
                        context.router.pop();
                      }
                      await widget.webViewController?.goForward();
                    }
                  : null,
            ),
          ],
        );
      },
    );
  }

  Future<void> _handleUrlSubmit(String url) async {
    var destination = url.trim();
    if (destination.isEmpty) return;

    if (!destination.startsWith('http://') && !destination.startsWith('https://')) {
      if (destination.contains('.') && !destination.contains(' ')) {
        destination = 'https://$destination';
      } else {
        destination = buildGoogleSearchUrl(destination);
      }
    }

    await widget.webViewController?.loadUrl(destination);
  }
}
