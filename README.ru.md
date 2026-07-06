# Shinga

[![English](https://img.shields.io/badge/lang-English-blue.svg)](README.md)
[![Русский](https://img.shields.io/badge/lang-Русский-red.svg)](README.ru.md)

Shinga - open-source Flutter-приложение для поиска, организации и чтения манги, манхвы, маньхуа, вебтунов, комиксов и новелл на Android и Windows.

Приложение строится вокруг личной библиотеки: можно найти тайтл, добавить его в закладки, отслеживать статус, сохранить ссылку для чтения и продолжить чтение во встроенном WebView или внешнем браузере.

## Возможности

- Просмотр и поиск тайтлов из каталога Shinga.
- Фильтрация и сортировка тайтлов.
- Организация закладок по статусу чтения.
- Сохранение и обновление ссылок для продолжения чтения с нужного места.
- Чтение во встроенном WebView со встроенным блокировщиком рекламы.
- Светлая и темная интерфейса.
- Переключение между русским и английским языками.
- Синхронизация аккаунта, закладок, оценок и данных чтения через Shinga API.

## Скачать

Скачайте приложение на [странице Releases](https://github.com/xEncerx/shinga-app/releases).

## Сборка из исходников

### Подготовка

```bash
git clone https://github.com/xEncerx/shinga-app.git
cd shinga-app
flutter pub get
```

Создайте `.env` на основе `.env.example`:

```bash
cp .env.example .env
```

Сгенерируйте локализацию и generated Dart-код:

```bash
dart run slang
dart run build_runner build --delete-conflicting-outputs
```

### Android

Release-сборка Android должна быть подписана. Поместите keystore в `android/app/release-keystore.jks` и создайте `android/app/key.properties`:

```properties
storeFile=release-keystore.jks
storePassword=
keyAlias=
keyPassword=
```

Не публикуйте keystore и `key.properties`.

```bash
flutter build apk --release --split-per-abi --dart-define-from-file=.env
```

### Windows

```bash
flutter build windows --release --dart-define-from-file=.env
```

## Поддерживаемые платформы

- Android 6.0+
- Windows 10+

## Связанные проекты

- [shinga-api](https://github.com/xEncerx/shinga-api) - backend API для аккаунтов, каталога, закладок, оценок и синхронизации.
- [webview_guardian](https://github.com/xEncerx/webview_guardian) - библиотека блокировки рекламы в WebView, используемая встроенным ридером.
