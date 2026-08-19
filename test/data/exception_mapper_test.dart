import 'package:shinga/core/types/types.dart';
import 'package:shinga/data/exception_mapper.dart';
import 'package:shinga/domain/failures/failures.dart';
import 'package:test/test.dart';

void main() {
  group('ExceptionMapper.guardVoid', () {
    test('returns Right when the command succeeds', () async {
      final result = await ExceptionMapper.guardVoid(() async {});

      expect(result, const Right<AppFailure, void>(null));
    });

    test('maps an exception to Left', () async {
      final result = await ExceptionMapper.guardVoid(() async => throw Exception('failure'));

      expect(result, isA<Left<AppFailure, void>>());
      final failure = (result as Left<AppFailure, void>).value;
      expect(failure, isA<UnknownNetworkFailure>());
      expect(failure.details, contains('failure'));
    });
  });
}
