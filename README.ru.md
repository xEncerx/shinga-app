# Shinga - Manga Tracker

[![Codemagic build status](https://api.codemagic.io/apps/68481494b4061c94a56eff5e/68481494b4061c94a56eff5d/status_badge.svg)](https://codemagic.io/app/68481494b4061c94a56eff5e/68481494b4061c94a56eff5d/latest_build)
[![English](https://img.shields.io/badge/lang-English-blue.svg)](README.md)
[![Русский](https://img.shields.io/badge/lang-Русский-red.svg)](README.ru.md)

> Современное кроссплатформенное приложение для поиска, отслеживания и чтения манги, созданное на Flutter с использованием современных архитектурных подходов.

## 📱 Скриншоты

<div align="center">
  <img src="screenshots/home_screen.png" width="200" alt="Главный экран"/>
  <img src="screenshots/search_screen.png" width="200" alt="Поиск манги"/>
  <img src="screenshots/manga_details.png" width="200" alt="Детали манги"/>
  <img src="screenshots/reading_screen.png" width="200" alt="Экран чтения"/>
</div>

## ✨ Особенности

### 🔍 **Поиск и обнаружение**
- Поиск манги по нескольким источникам (Remanga, MangaPoisk, Shikimori)
- Автодополнение при поиске
- История поиска
- Глобальный поиск по всем доступным источникам

### 📚 **Управление библиотекой**
- Организация манги по разделам: "Читаю", "Прочитано", "На будущее", "Не читаю"
- Отслеживание прогресса чтения
- Сохранение текущих URL для продолжения чтения
- Синхронизация с облачным API

### 📖 **Удобное чтение**
- Встроенный WebView для чтения на мобильных устройствах
- Поддержка внешних браузеров на десктопе
- Автоматическое обновление URL при смене главы

### 🎨 **Современный интерфейс**
- Адаптивный дизайн для всех платформ
- Два стиля отображения: карточки и плитки
- Темная и светлая темы
- Скелетон-загрузчики для улучшенного UX

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

1. Создайте файл `.env` в корне проекта:
```env
API_BASE_URL=your_api_base_url
```

2. Генерация кода:
```bash
dart run build_runner build --delete-conflicting-outputs
```

3. Конфигурация языков для ios
```bash
dart run slang configure
```

### Запуск приложения

```bash
# Для отладки
flutter run

# Для конкретной платформы
flutter run -d chrome        # Web
flutter run -d windows       # Windows
flutter run -d android       # Android
flutter run -d ios          # iOS
```

## 📦 Сборка для продакшена

### Android
```bash
flutter build apk --release --split-per-abi
# или
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

## 🧪 Тестирование (планируется)

```bash
# Запуск всех тестов
flutter test

# Запуск с покрытием
flutter test --coverage
```

## 📱 Поддерживаемые платформы

- ✅ Android (API 21+)
- ❓ iOS (11.0+) (Должно работать, в теории)
- ✅ Windows (10+)
- ✅ Web (современные браузеры)
- ⏳ macOS (планируется)
- ⏳ Linux (планируется)

## 🔗 Связанные проекты

### Backend API Service
REST API сервис для Shinga, обеспечивающий синхронизацию данных и доступ к библиотеке манги.
> **Примечание**: Репозиторий API сервиса будет доступен в ближайшее время

## 🤝 Contributing

Буду рад вашим предложениям и улучшениям! Пожалуйста:

1. Форкните репозиторий
2. Создайте feature-ветку (`git checkout -b feature/amazing-feature`)
3. Зафиксируйте изменения (`git commit -m 'Add amazing feature'`)
4. Отправьте в ветку (`git push origin feature/amazing-feature`)
5. Откройте Pull Request

## 📄 Лицензия

Этот проект распространяется под лицензией MIT. Подробности в файле [LICENSE](LICENSE).

---

<div align="center">
  <p>Сделано с ❤️ для демонстрации навыков разработки на Flutter</p>
</div>