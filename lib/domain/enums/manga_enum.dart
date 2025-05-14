enum MangaSection {
  reading("читаю"),
  completed("прочитано"),
  onFuture("на будущие"),
  notReading("не читаю"),
  any("*");

  const MangaSection(this.name);

  final String name;
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
