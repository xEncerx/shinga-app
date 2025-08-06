# 📚 Shinga - Manga Tracker

[![Codemagic build status](https://api.codemagic.io/apps/68481494b4061c94a56eff5e/68481494b4061c94a56eff5d/status_badge.svg)](https://codemagic.io/app/68481494b4061c94a56eff5e/68481494b4061c94a56eff5d/latest_build)
[![English](https://img.shields.io/badge/lang-English-blue.svg)](README.md)
[![Русский](https://img.shields.io/badge/lang-Русский-red.svg)](README.ru.md)

> Cross-platform application for searching, tracking, and reading manga.

## 📱 Screenshots

Coming soon
<!-- <div align="center">
  <img src="screenshots/home_screen.png" width="200" alt="Home Screen"/>
  <img src="screenshots/search_screen.png" width="200" alt="Manga Search"/>
  <img src="screenshots/manga_details.png" width="200" alt="Manga Details"/>
</div> -->

## ✨ Features

### 🔍 **Title Search**
- 🌐 Integration with multiple sources (Remanga, MyAnimeList, Shikimori)
- 🎯 Smart search with filtering and result sorting
- 📝 Search autocomplete
- 📊 Search history

### 📚 **Library Management**
- 📂 Organize manga by categories: "Reading", "Completed", "Planned", "Dropped"
- 📈 Reading progress tracking
- 🔗 Save current URLs to continue reading
- ☁️ Cloud API synchronization

### 📖 **Convenient Reading**
- 🌐 Built-in WebView for reading on mobile devices
- 💻 External browser support on desktop

### 🌐 **Multilingual Support**
- Support for Russian and English languages
- Localization of all interface elements

## 🚀 Installation and Setup
### Repository Cloning

```bash
git clone https://github.com/xEncerx/shinga-app.git
cd shinga-app
```

### Install Dependencies

```bash
flutter pub get
```

### Environment Setup

1. Create a `config.json` file (based on `config.example.json`) in the project root.

2. Code generation:
```bash
dart run slang

dart run build_runner build --delete-conflicting-outputs
```

## 📦 Application Build

#### Android
```bash
flutter build apk --release --split-per-abi --dart-define-from-file=config.json
```

#### Windows
```bash
flutter build windows --release --dart-define-from-file=config.json
```

## 📱 Supported Platforms

- ✅ Android (API 23+)
- ⏳ iOS (planned)
- ✅ Windows (10+)
- ❌ Web
- ⏳ macOS (planned)
- ⏳ Linux (planned)

## 🔗 Related Projects

### 🌐 Shinga Api
> REST API service for Shinga, providing data synchronization and access to the manga library.
- **Repository**: [shinga-api](https://github.com/xEncerx/shinga-api)
---

<div align="center">
  <p>Made with ❤️ for manga lovers</p>
</div>