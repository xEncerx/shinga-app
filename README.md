# Shinga

[![English](https://img.shields.io/badge/lang-English-blue.svg)](README.md)
[![Русский](https://img.shields.io/badge/lang-Русский-red.svg)](README.ru.md)

Shinga is an open-source Flutter app for discovering, organizing, and reading manga, manhwa, manhua, webtoons, comics, and novels across Android and Windows.

The app is built around a personal library: find a title, add it to bookmarks, track its status, keep a reading link, and continue reading either in the built-in WebView reader or in an external browser.

## Features

- Browse and search titles from the Shinga catalog.
- Filter and sort titles.
- Organize bookmarks by reading status.
- Save and update reading URLs to continue from the right place.
- Read in a built-in WebView with a built-in ad blocker.
- Use light or dark interface.
- Switch between English and Russian languages.
- Sync account, bookmarks, ratings, and reading data through the Shinga API.

## Download

Get the app from our [Releases page](https://github.com/xEncerx/shinga-app/releases).

## Build from source

### Setup

```bash
git clone https://github.com/xEncerx/shinga-app.git
cd shinga-app
flutter pub get
```

Create `.env` based on `.env.example`:

```bash
cp .env.example .env
```

Generate localization and generated Dart code:

```bash
dart run slang
dart run build_runner build --delete-conflicting-outputs
```

### Android

Release Android builds must be signed. Put your keystore at `android/app/release-keystore.jks` and create `android/app/key.properties`:

```properties
storeFile=release-keystore.jks
storePassword=
keyAlias=
keyPassword=
```

Keep the keystore and `key.properties` private.

```bash
flutter build apk --release --split-per-abi --dart-define-from-file=.env
```

### Windows

```bash
flutter build windows --release --dart-define-from-file=.env
```

## Supported platforms

- Android 6.0+
- Windows 10+

## Related projects

- [shinga-api](https://github.com/xEncerx/shinga-api) - backend API for accounts, catalog data, bookmarks, ratings, and synchronization.
- [webview_guardian](https://github.com/xEncerx/webview_guardian) - WebView ad-blocking library used by the built-in reader.
