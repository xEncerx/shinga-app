enum MangaSection {
  reading("читаю"),
  completed("прочитано"),
  onFuture("на будущие"),
  notReading("не читаю"),
  any("*");

  const MangaSection(this.name);

  final String name;
  static List<MangaSection> get activeSections => [
    MangaSection.reading,
    MangaSection.completed,
    MangaSection.onFuture,
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
}
