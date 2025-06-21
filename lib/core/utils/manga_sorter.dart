import 'package:string_similarity/string_similarity.dart';

import '../../data/data.dart';
import '../core.dart';

/// Utility class for sorting manga collections.
class MangaSorter {
  /// Sorts a list of manga based on specified criteria.
  ///
  /// Returns the sorted list according to [sortingMethod] and [sortingOrder].
  /// If [nameFilter] is provided for name sorting, uses similarity matching.
  ///
  /// - `mangas`: List of manga to sort.
  /// - `sortingMethod`: The method to sort by, defaults to [SortingEnum.defaultValue].
  /// - `sortingOrder`: The order of sorting, defaults to [SortingOrder.defaultValue].
  /// - `nameFilter`: Optional filter for name sorting, used to find similar names.
  List<Manga?> sort({
    required List<Manga?> mangas,
    SortingEnum sortingMethod = SortingEnum.defaultValue,
    SortingOrder sortingOrder = SortingOrder.defaultValue,
    String? nameFilter,
  }) {
    if (mangas.isEmpty) {
      return mangas;
    }

    // Sort the mangas based on the selected sorting method
    switch (sortingMethod) {
      case SortingEnum.lastUpdateTime:
        _compareByLastUpdateTime(mangas);
      case SortingEnum.name:
        _sortByNameWithFilter(mangas, nameFilter);
      case SortingEnum.date:
        _compareByDate(mangas);
      case SortingEnum.rating:
        _compareByRating(mangas);
      case SortingEnum.chapters:
        _compareByChapters(mangas);
      case SortingEnum.views:
        _compareByViews(mangas);
      case SortingEnum.status:
        _compareByStatus(mangas);
    }

    // Sort the mangas based on the selected sorting order
    if (sortingOrder == SortingOrder.desc) {
      return mangas.reversed.toList();
    }
    return mangas;
  }

  /// Compares the last update time of manga and sorts them accordingly.
  List<Manga?> _compareByLastUpdateTime(List<Manga?> mangas) {
    return mangas..sort(
      (a, b) {
        final DateTime aLastUpdate = a?.lastRead ?? DateTime.fromMillisecondsSinceEpoch(0);
        final DateTime bLastUpdate = b?.lastRead ?? DateTime.fromMillisecondsSinceEpoch(0);
        return aLastUpdate.compareTo(bLastUpdate);
      },
    );
  }

  /// Sorts manga by name using string similarity if a name filter is provided.
  List<Manga?> _sortByNameWithFilter(List<Manga?> mangas, String? nameFilter) {
    if (nameFilter == null || nameFilter.isEmpty) {
      // Sort by name alphabetically if no filter is applied
      return mangas..sort((a, b) {
        final String aName = (a?.name ?? '').toLowerCase();
        final String bName = (b?.name ?? '').toLowerCase();
        return aName.compareTo(bName);
      });
    } else {
      // Sort by similarity to the name filter
      final String filterLower = nameFilter.toLowerCase();
      return mangas..sort((a, b) {
        final String aName = (a?.name ?? '').toLowerCase();
        final String bName = (b?.name ?? '').toLowerCase();

        final double aSimilarity = aName.similarityTo(filterLower);
        final double bSimilarity = bName.similarityTo(filterLower);

        return aSimilarity.compareTo(bSimilarity);
      });
    }
  }

  /// Compares the date of manga and sorts them accordingly.
  List<Manga?> _compareByDate(List<Manga?> mangas) {
    return mangas..sort(
      (a, b) {
        final int aDate = a?.year ?? 0;
        final int bDate = b?.year ?? 0;
        return aDate.compareTo(bDate);
      },
    );
  }

  /// Compares the rating of manga and sorts them accordingly.
  List<Manga?> _compareByRating(List<Manga?> mangas) {
    return mangas..sort(
      (a, b) {
        final double aRating = double.tryParse(a?.avgRating ?? '') ?? 0.0;
        final double bRating = double.tryParse(b?.avgRating ?? '') ?? 0.0;
        return aRating.compareTo(bRating);
      },
    );
  }

  /// Compares the chapters of manga and sorts them accordingly.
  List<Manga?> _compareByChapters(List<Manga?> mangas) {
    return mangas..sort(
      (a, b) {
        final int aChapters = a?.chapters ?? 0;
        final int bChapters = b?.chapters ?? 0;
        return aChapters.compareTo(bChapters);
      },
    );
  }

  /// Compares the views of manga and sorts them accordingly.
  List<Manga?> _compareByViews(List<Manga?> mangas) {
    return mangas..sort(
      (a, b) {
        final int aViews = a?.views ?? 0;
        final int bViews = b?.views ?? 0;
        return aViews.compareTo(bViews);
      },
    );
  }

  /// Compares the status of manga and sorts them accordingly.
  List<Manga?> _compareByStatus(List<Manga?> mangas) {
    return mangas..sort(
      (a, b) {
        final MangaStatus aStatus = MangaStatus.fromName(a?.status ?? '');
        final MangaStatus bStatus = MangaStatus.fromName(b?.status ?? '');

        return bStatus.index.compareTo(aStatus.index);
      },
    );
  }
}
