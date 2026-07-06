import 'package:fpdart/fpdart.dart';
import 'package:shinga/domain/domain.dart';

/// Contract for fetching available filter options for titles.
abstract class TitleFilterRepository {
  /// Fetches the list of available genre form options.
  Future<Either<AppFailure, List<TitleGenre>>> getGenreForms();

  /// Fetches the list of available category form options.
  Future<Either<AppFailure, List<TitleCategory>>> getCategoryForms();

  /// Fetches the list of available publication status form options.
  Future<Either<AppFailure, List<TitleStatus>>> getStatusForms();

  /// Fetches the list of available publication type form options.
  Future<Either<AppFailure, List<TitleType>>> getTypeForms();
}
