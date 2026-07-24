# System Proxy Reader

Reads the current user's system proxy configuration.

Windows is currently supported through the native WinHTTP API and Dart FFI. The reader
returns manual proxy settings, bypass rules, and PAC/WPAD metadata. It does not execute
PAC scripts.

## Usage

```dart
import 'dart:io';

import 'package:system_proxy_reader/system_proxy_reader.dart';

if (Platform.isWindows) {
  final settings = WindowsProxyReader().read();
  print(settings.proxy ?? 'DIRECT');
}
```
