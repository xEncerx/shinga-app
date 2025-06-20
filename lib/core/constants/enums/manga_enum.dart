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
  date,
  rating,
  chapters,
  status,
}

/// Sorting direction options.
enum SortingOrder { asc, desc }

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
