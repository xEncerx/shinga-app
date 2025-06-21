import '../../../i18n/strings.g.dart';

/// Represents different reading status sections for manga.
enum MangaSection {
  reading("читаю"),
  completed("прочитано"),
  onFuture("на будущие"),
  notReading("не читаю"),

  /// Represents any section.
  any("*");

  /// Creates a manga section with the specified name.
  const MangaSection(this.name);

  /// Display name of the section.
  final String name;

  /// List of sections that contain active manga.
  static List<MangaSection> get activeSections => [
    MangaSection.completed,
    MangaSection.reading,
    MangaSection.onFuture,
  ];

  /// List of sections that can be selected by user.
  static List<MangaSection> get selectableSections => [
    MangaSection.notReading,
    ...activeSections,
  ];
}

/// Available sorting criteria for manga lists.
enum SortingEnum {
  name,
  lastUpdateTime,
  date,
  rating,
  chapters,
  views,
  status;

  /// Default Sorting method
  static const SortingEnum defaultValue = SortingEnum.lastUpdateTime;

  /// Returns the localized name of the sorting method.
  String getLocalizedName() {
    switch (this) {
      case SortingEnum.lastUpdateTime:
        return t.sorting.byLastUpdateTime;
      case SortingEnum.name:
        return t.sorting.byName;
      case SortingEnum.date:
        return t.sorting.byYear;
      case SortingEnum.rating:
        return t.sorting.byRating;
      case SortingEnum.chapters:
        return t.sorting.byChapters;
      case SortingEnum.views:
        return t.sorting.byViews;
      case SortingEnum.status:
        return t.sorting.byStatus;
    }
  }
}

/// Sorting direction options.
enum SortingOrder {
  asc,
  desc;

  /// Default Sorting order
  static const SortingOrder defaultValue = SortingOrder.desc;

  /// Returns the localized name of the sorting order.
  String getLocalizedName() {
    switch (this) {
      case SortingOrder.asc:
        return t.sorting.order.asc;
      case SortingOrder.desc:
        return t.sorting.order.desc;
    }
  }
}

/// Supported manga content providers.
enum MangaSource {
  // Providers
  remanga('remanga'),
  shikimori('shikimori'),
  mangaPoisk('manga_poisk');

  /// Creates a manga source with the specified internal name.
  const MangaSource(this.name);

  /// Internal name used for API communication.
  final String name;

  /// List of providers suggested for content search.
  static List<MangaSource> get suggestProviders => [
    MangaSource.remanga,
    MangaSource.mangaPoisk,
  ];

  /// Finds a [MangaSource] by its internal name.
  ///
  /// Throws an exception if no matching source is found.
  static MangaSource fromName(String name) {
    return values.firstWhere(
      (source) => source.name == name,
      orElse: () => throw Exception("Unknown source name: $name"),
    );
  }
}

enum MangaStatus {
  released("Закончен"),
  ongoing("Продолжается"),
  licensed("Лицензировано"),
  frozen("Заморожен"),
  noTranslator("Нет переводчика"),
  anons("Анонс"),
  unknown("Неизвестно");

  /// Creates a manga status with the specified name.
  const MangaStatus(this.name);

  /// Display name of the status.
  final String name;

  /// Returns the [MangaStatus] corresponding to the given name.
  static MangaStatus fromName(String name) {
    return values.firstWhere(
      (status) => status.name == name,
      orElse: () => MangaStatus.unknown,
    );
  }
}
