import 'package:shinga/core/types/types.dart';
import 'package:shinga/data/data.dart';
import 'package:shinga/domain/domain.dart';
import 'package:shinga/features/features.dart';

/// Implementation of [TitleFilterRepository] backed by [TitleFormApiClient].
class TitleFilterRepositoryImpl implements TitleFilterRepository {
  /// Creates a [TitleFilterRepositoryImpl] instance.
  const TitleFilterRepositoryImpl(TitleFormApiClient titleFormApiClient)
    : _titleFormApiClient = titleFormApiClient;

  final TitleFormApiClient _titleFormApiClient;

  @override
  Future<Either<AppFailure, List<TitleGenre>>> getGenreForms() {
    return ExceptionMapper.guard(() async {
      final response = await _titleFormApiClient.getGenreForms();
      return response.content.map((dto) => dto.toDomain()).toList();
    });
  }

  @override
  Future<Either<AppFailure, List<TitleCategory>>> getCategoryForms() {
    return ExceptionMapper.guard(() async {
      final response = await _titleFormApiClient.getCategoryForms();
      return response.content.map((dto) => dto.toDomain()).toList();
    });
  }

  @override
  Future<Either<AppFailure, List<TitleStatus>>> getStatusForms() {
    return ExceptionMapper.guard(() async {
      final response = await _titleFormApiClient.getStatusForms();
      return response.content.map((dto) => dto.toDomain()).toList();
    });
  }

  @override
  Future<Either<AppFailure, List<TitleType>>> getTypeForms() {
    return ExceptionMapper.guard(() async {
      final response = await _titleFormApiClient.getTypeForms();
      return response.content.map((dto) => dto.toDomain()).toList();
    });
  }
}
