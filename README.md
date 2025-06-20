# Shinga - Manga Tracker

[![Codemagic build status](https://api.codemagic.io/apps/68481494b4061c94a56eff5e/68481494b4061c94a56eff5d/status_badge.svg)](https://codemagic.io/app/68481494b4061c94a56eff5e/68481494b4061c94a56eff5d/latest_build)
[![English](https://img.shields.io/badge/lang-English-blue.svg)](README.md)
[![Русский](https://img.shields.io/badge/lang-Русский-red.svg)](README.ru.md)

> A modern cross-platform application for searching, tracking, and reading manga, built with Flutter using modern architectural approaches.

## 📱 Screenshots

<div align="center">
  <img src="screenshots/home_screen.png" width="200" alt="Home Screen"/>
  <img src="screenshots/search_screen.png" width="200" alt="Search Screen"/>
  <img src="screenshots/manga_details.png" width="200" alt="Manga Details"/>
</div>

## ✨ Features

### 🔍 **Search and Discovery**
- Search manga across multiple sources (Remanga, MangaPoisk, Shikimori)
- Search autocompletion
- Search history
- Global search across all available sources

### 📚 **Library Management**
- Organize manga by categories: "Reading", "Completed", "Plan to Read", "Dropped"
- Track reading progress
- Save current URLs to continue reading
- Cloud API synchronization

### 📖 **Convenient Reading**
- Built-in WebView for reading on mobile devices
- External browser support on desktop
- Automatic URL updates when changing chapters

### 🎨 **Modern Interface**
- Responsive design for all platforms
- Two display styles: cards and tiles
- Dark and light themes
- Skeleton loaders for enhanced UX

### 🌐 **Multilingual Support**
- Support for Russian and English languages
- Localization of all interface elements

## 🚀 Installation and Setup
### Clone Repository

```bash
git clone https://github.com/xEncerx/shinga-app.git
cd shinga-app
```

### Install Dependencies

```bash
flutter pub get
```

### Environment Setup

1. Create a `.env` file in the project root:
```env
API_BASE_URL=your_api_base_url
```

2. Code generation:
```bash
dart run build_runner build --delete-conflicting-outputs
```

3. Language configuration for iOS:
```bash
dart run slang configure
```

### Run Application

```bash
# For debugging
flutter run

# For specific platform
flutter run -d chrome        # Web
flutter run -d windows       # Windows
flutter run -d android       # Android
flutter run -d ios          # iOS
```

## 📦 Production Build

### Android
```bash
flutter build apk --release --split-per-abi
# or
flutter build appbundle --release
```

### iOS
```bash
flutter build ipa --release
```

### Windows
```bash
flutter build windows --release
```

### Web
```bash
flutter build web --release
```

## 🧪 Testing (planned)

```bash
# Run all tests
flutter test

# Run with coverage
flutter test --coverage
```

## 📱 Supported Platforms

- ✅ Android (API 21+)
- ❓ iOS (11.0+) (Should work, in theory)
- ✅ Windows (10+)
- ✅ Web (modern browsers)
- ⏳ macOS (planned)
- ⏳ Linux (planned)

## 🔗 Related Projects

### Backend API Service
REST API service for Shinga, providing data synchronization and access to manga library.
> **Note**: API service repository will be available soon

## 🤝 Contributing

I welcome your suggestions and improvements! Please:

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📄 License

This project is distributed under the MIT License. See [LICENSE](LICENSE) for details.

---

<div align="center">
  <p>Made with ❤️ to demonstrate Flutter development skills</p>
</div>