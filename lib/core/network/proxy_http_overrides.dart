import 'dart:io';

import 'package:detect_proxy_setting/detect_proxy_setting.dart';

/// An [HttpOverrides] implementation that configures the HTTP client to use system proxy settings.
class ProxyHttpOverrides extends HttpOverrides {
  /// Creates a [ProxyHttpOverrides] instance.
  ProxyHttpOverrides(this.proxySettings);

  /// The proxy settings to apply to the HTTP client.
  final ProxySetting? proxySettings;

  @override
  HttpClient createHttpClient(SecurityContext? context) {
    final client = super.createHttpClient(context)
      ..findProxy = (uri) {
        if (proxySettings == null || proxySettings!.mode == ProxySettingModeEnum.direct) {
          return 'DIRECT';
        } else {
          final cleanProxy = proxySettings!.proxy
              .replaceAll('http://', '')
              .replaceAll('https://', '');

          return 'PROXY $cleanProxy; DIRECT';
        }
      };

    return client;
  }
}
