import 'package:either_dart/either.dart';

import '../../../../core/core.dart';
import 'base_remote_datasource.dart';

/// A data source for utility functions that interact with the remote API.
///
/// Provides methods for system utilities and diagnostics including:
/// - System status verification
class UtilsRemoteDataSource extends BaseRemoteDataSource {
  /// Creates a new instance of [UtilsRemoteDataSource].
  /// 
  /// - `dio` - The Dio HTTP client instance used for making API requests.
  UtilsRemoteDataSource(super.dio);

  /// Pings the server to check if it is reachable.
  Future<Either<ApiException, Map<String, dynamic>>> ping() async {
    return executeRequest(
      endpoint: "/utils/ping",
      method: "GET",
    );
  }
}
