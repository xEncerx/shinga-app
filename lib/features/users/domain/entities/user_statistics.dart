import 'package:equatable/equatable.dart';
import 'package:shinga/domain/domain.dart';

/// Aggregated statistics for the current user profile.
class UserStatisticsEntity extends Equatable {
  /// Creates a [UserStatisticsEntity] instance.
  const UserStatisticsEntity({
    required this.bookmarks,
    required this.ratings,
  });

  /// Bookmark statistics grouped by status.
  final UserBookmarkStatisticsEntity bookmarks;

  /// Rating statistics grouped by score.
  final UserRatingStatisticsEntity ratings;

  @override
  List<Object?> get props => [bookmarks, ratings];
}

/// Bookmark statistics for the current user.
class UserBookmarkStatisticsEntity extends Equatable {
  /// Creates a [UserBookmarkStatisticsEntity] instance.
  const UserBookmarkStatisticsEntity({
    required this.bookmarks,
    required this.total,
  });

  /// Counts by bookmark status. Only positive values are included.
  final Map<Bookmark, int> bookmarks;

  /// Total number of bookmarked titles.
  final int total;

  @override
  List<Object?> get props => [bookmarks, total];
}

/// Rating statistics for the current user.
class UserRatingStatisticsEntity extends Equatable {
  /// Creates a [UserRatingStatisticsEntity] instance.
  const UserRatingStatisticsEntity({
    required this.averageRating,
    required this.ratingsCount,
    required this.ratingsDistribution,
  });

  /// Average user rating.
  final double averageRating;

  /// Number of rated titles.
  final int ratingsCount;

  /// Distribution of ratings keyed by score.
  final Map<int, int> ratingsDistribution;

  @override
  List<Object?> get props => [averageRating, ratingsCount, ratingsDistribution];
}
