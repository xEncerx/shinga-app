import 'dart:io';

import 'package:system_proxy_reader/system_proxy_reader.dart';

/// An [HttpOverrides] implementation that configures the HTTP client to use system proxy settings.
class ProxyHttpOverrides extends HttpOverrides {
  /// Creates a [ProxyHttpOverrides] instance.
  ProxyHttpOverrides(this.proxySettings);

  /// The proxy settings to apply to the HTTP client.
  final SystemProxySettings proxySettings;

  /// Resolves the manual system proxy for [uri].
  String findProxy(Uri uri) {
    if (_shouldBypass(uri)) return 'DIRECT';

    final proxy = _proxyForScheme(uri.scheme);
    return proxy == null ? 'DIRECT' : 'PROXY $proxy';
  }

  @override
  HttpClient createHttpClient(SecurityContext? context) {
    final client = super.createHttpClient(context)..findProxy = findProxy;

    return client;
  }

  String? _proxyForScheme(String scheme) {
    final proxyList = proxySettings.proxy;
    if (proxyList == null) return null;

    String? defaultProxy;
    for (final rawEntry in proxyList.split(';')) {
      final entry = rawEntry.trim();
      if (entry.isEmpty) continue;

      final separator = entry.indexOf('=');
      if (separator == -1) {
        defaultProxy ??= _normalizeProxy(entry);
        continue;
      }

      final entryScheme = entry.substring(0, separator).trim();
      if (entryScheme.toLowerCase() == scheme.toLowerCase()) {
        return _normalizeProxy(entry.substring(separator + 1));
      }
    }

    return defaultProxy;
  }

  bool _shouldBypass(Uri uri) {
    final bypassList = proxySettings.proxyBypass;
    if (bypassList == null) return false;

    for (final rawRule in bypassList.split(';')) {
      var rule = rawRule.trim();
      if (rule.isEmpty) continue;

      if (rule.toLowerCase() == '<local>') {
        if (!uri.host.contains('.')) return true;
        continue;
      }

      rule = rule.replaceFirst(RegExp('^[a-z][a-z0-9+.-]*://', caseSensitive: false), '');
      rule = rule.replaceFirst(RegExp(r'/+$'), '');
      if (_matchesRule(rule, uri.host) || _matchesRule(rule, '${uri.host}:${uri.port}')) {
        return true;
      }
    }

    return false;
  }
}

String? _normalizeProxy(String value) {
  var proxy = value.trim();
  proxy = proxy.replaceFirst(
    RegExp('^(?:https?|socks(?:4|5)?)://', caseSensitive: false),
    '',
  );
  proxy = proxy.replaceFirst(RegExp(r'/+$'), '');
  return proxy.isEmpty ? null : proxy;
}

bool _matchesRule(String rule, String value) {
  final pattern = RegExp.escape(rule).replaceAll(r'\*', '.*').replaceAll(r'\?', '.');
  return RegExp('^$pattern\$', caseSensitive: false).hasMatch(value);
}
