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

enum MangaSource {
  remanga,
  shikimori,
  manga_poisk;

  static MangaSource fromName(String name) {
    switch (name) {
      case "remanga":
        return MangaSource.remanga;
      case "shikimori":
        return MangaSource.shikimori;
      case "manga_poisk":
        return MangaSource.manga_poisk;
      default:
        throw Exception("Unknown source name: $name");
    }
  }
}
