import 'package:either_dart/either.dart';

import '../../../core/core.dart';
import '../../../data/data.dart';

class UtilsRepository {
  UtilsRepository(this._remoteDataSource);

  final UtilsRemoteDataSource _remoteDataSource;

  Future<Either<ApiException, bool>> ping() async {
    final result = await _remoteDataSource.ping();

    return result.fold(
      (error) => Left(error),
      (data) => Right(result.isLeft),
    );
  }
}
