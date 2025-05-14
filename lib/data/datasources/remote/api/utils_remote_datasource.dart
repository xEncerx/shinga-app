import 'package:either_dart/either.dart';

import '../../../../core/core.dart';
import 'base_remote_datasource.dart';

class UtilsRemoteDataSource extends BaseRemoteDataSource {
  UtilsRemoteDataSource(super.dio);

  Future<Either<ApiException, Map<String, dynamic>>> ping() async {
    return executeRequest(
      endpoint: "/utils/ping",
      method: "GET",
    );
  }
}
