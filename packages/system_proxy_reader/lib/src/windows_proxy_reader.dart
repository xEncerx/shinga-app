import 'dart:ffi';
import 'dart:io';

import 'package:ffi/ffi.dart';
import 'package:system_proxy_reader/src/system_proxy_models.dart';
import 'package:system_proxy_reader/src/system_proxy_reader.dart';

const _errorFileNotFound = 2;

/// Reads the current user's Windows proxy configuration through WinHTTP.
final class WindowsProxyReader implements SystemProxyReader {
  /// Creates a Windows system proxy reader.
  const WindowsProxyReader();

  @override
  SystemProxySettings read() {
    if (!Platform.isWindows) {
      throw UnsupportedError('WindowsProxyReader is only supported on Windows.');
    }

    final bindings = _WindowsProxyBindings();
    final configPointer = calloc<_WinHttpCurrentUserIeProxyConfig>();

    try {
      final succeeded = bindings.getCurrentUserProxyConfig(configPointer) != 0;
      if (!succeeded) {
        final errorCode = bindings.getLastError();
        if (errorCode == _errorFileNotFound) {
          return const SystemProxySettings();
        }

        throw SystemProxyReadException(
          'WinHTTP could not read the current user proxy configuration.',
          errorCode: errorCode,
        );
      }

      final config = configPointer.ref;
      return SystemProxySettings(
        autoDetect: config.autoDetect != 0,
        autoConfigUrl: _readString(config.autoConfigUrl),
        proxy: _readString(config.proxy),
        proxyBypass: _readString(config.proxyBypass),
      );
    } finally {
      final config = configPointer.ref;
      bindings
        ..free(config.autoConfigUrl)
        ..free(config.proxy)
        ..free(config.proxyBypass);
      calloc.free(configPointer);
    }
  }
}

String? _readString(Pointer<Utf16> pointer) {
  if (pointer == nullptr) return null;

  final value = pointer.toDartString().trim();
  return value.isEmpty ? null : value;
}

final class _WindowsProxyBindings {
  factory _WindowsProxyBindings() {
    final winHttp = DynamicLibrary.open('winhttp.dll');
    final kernel32 = DynamicLibrary.open('kernel32.dll');

    return _WindowsProxyBindings._(
      winHttp.lookupFunction<
        Int32 Function(Pointer<_WinHttpCurrentUserIeProxyConfig>),
        _GetCurrentUserProxyConfig
      >('WinHttpGetIEProxyConfigForCurrentUser'),
      kernel32.lookupFunction<Pointer<Void> Function(Pointer<Void>), _GlobalFree>('GlobalFree'),
      kernel32.lookupFunction<Uint32 Function(), _GetLastError>('GetLastError'),
    );
  }

  _WindowsProxyBindings._(
    this._getCurrentUserProxyConfig,
    this._globalFree,
    this.getLastError,
  );

  final _GetCurrentUserProxyConfig _getCurrentUserProxyConfig;
  final _GlobalFree _globalFree;
  final _GetLastError getLastError;

  int getCurrentUserProxyConfig(Pointer<_WinHttpCurrentUserIeProxyConfig> config) {
    return _getCurrentUserProxyConfig(config);
  }

  void free(Pointer<Utf16> pointer) {
    if (pointer != nullptr) _globalFree(pointer.cast());
  }
}

final class _WinHttpCurrentUserIeProxyConfig extends Struct {
  @Int32()
  external int autoDetect;

  external Pointer<Utf16> autoConfigUrl;

  external Pointer<Utf16> proxy;

  external Pointer<Utf16> proxyBypass;
}

typedef _GetCurrentUserProxyConfig = int Function(Pointer<_WinHttpCurrentUserIeProxyConfig> config);
typedef _GlobalFree = Pointer<Void> Function(Pointer<Void> memory);
typedef _GetLastError = int Function();
