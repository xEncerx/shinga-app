# 📚 Shinga - Manga Tracker

[![Codemagic build status](https://api.codemagic.io/apps/68481494b4061c94a56eff5e/68481494b4061c94a56eff5d/status_badge.svg)](https://codemagic.io/app/68481494b4061c94a56eff5e/68481494b4061c94a56eff5d/latest_build)
[![English](https://img.shields.io/badge/lang-English-blue.svg)](README.md)
[![Русский](https://img.shields.io/badge/lang-Русский-red.svg)](README.ru.md)

> Кроссплатформенное приложение для поиска, отслеживания и чтения манги.

## 📱 Скриншоты

Скоро будут
<!-- <div align="center">
  <img src="screenshots/home_screen.png" width="200" alt="Главный экран"/>
  <img src="screenshots/search_screen.png" width="200" alt="Поиск манги"/>
  <img src="screenshots/manga_details.png" width="200" alt="Детали манги"/>
</div> -->

## ✨ Особенности

### 🔍 **Поиск тайлтлов**
- 🌐 Интеграция с несколькими источниками (Remanga, MyAnimeList, Shikimori)
- 🎯 Умный поиск с фильтрацией и сортировкой результатов
- 📝 Автодополнение при поиске
- 📊 История поисковых запросов

### 📚 **Управление библиотекой**
- 📂 Организация манги по категориям: "Читаю", "Завершено", "Планирую", "Брошено"
- 📈 Отслеживание прогресса чтения
- 🔗 Сохранение текущих URL для продолжения чтения
- ☁️ Синхронизация с облачным API

### 📖 **Удобное чтение**
- 🌐 Встроенный WebView для чтения на мобильных устройствах
- 💻 Поддержка внешних браузеров на десктопе

### 🌐 **Мультиязычность**
- Поддержка русского и английского языков
- Локализация всех элементов интерфейса

## 🚀 Установка и запуск
### Клонирование репозитория

```bash
git clone https://github.com/xEncerx/shinga-app.git
cd shinga-app
```

### Установка зависимостей

```bash
flutter pub get
```

### Настройка окружения

1. Создайте файл `config.json`(на основе `config.example.json`) в корне проекта.


2. Генерация кода:
```bash
dart run slang

dart run build_runner build --delete-conflicting-outputs
```

### 📦 Сборка приложения

#### Android
```bash
flutter build apk --release --split-per-abi --dart-define-from-file=config.json
```

#### Windows
```bash
flutter build windows --release --dart-define-from-file=config.json
```

## 📱 Поддерживаемые платформы

- ✅ Android (API 23+)
- ⏳ iOS (планируется)
- ✅ Windows (10+)
- ❌ Web
- ⏳ macOS (планируется)
- ⏳ Linux (планируется)

## 🔗 Связанные проекты

### 🌐 Shinga Api
> REST API сервис для Shinga, обеспечивающий синхронизацию данных и доступ к библиотеке манги.
- **Репозиторий**: [shinga-api](https://github.com/xEncerx/shinga-api)
---

<div align="center">
  <p>Создано с ❤️ для любителей манги</p>
</div>