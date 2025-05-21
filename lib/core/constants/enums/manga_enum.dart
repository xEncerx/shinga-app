enum MangaSection {
  reading("читаю"),
  completed("прочитано"),
  onFuture("на будущие"),
  notReading("не читаю"),
  any("*");

  const MangaSection(this.name);

  final String name;
  static List<MangaSection> get activeSections => [
    MangaSection.completed,
    MangaSection.reading,
    MangaSection.onFuture,
  ];
  static List<MangaSection> get selectableSections => [
    MangaSection.notReading,
    ...activeSections
  ];
}

enum SortingEnum {
  name,
  date,
  rating,
  chapters,
  status;
}

enum SortingOrder{
    ascending,
    descending;
  }

enum MangaSource {
  remanga('remanga'),
  shikimori('shikimori'),
  mangaPoisk('manga_poisk');

  const MangaSource(this.name);
  
  final String name;

  static List<MangaSource> get suggestProviders => [
    MangaSource.remanga,
    MangaSource.mangaPoisk,
  ];

  static MangaSource fromName(String name) {
    return values.firstWhere(
      (source) => source.name == name,
      orElse: () => throw Exception("Unknown source name: $name"),
    );
  }
}
