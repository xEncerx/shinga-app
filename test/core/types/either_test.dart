import 'package:shinga/core/types/types.dart';
import 'package:test/test.dart';

void main() {
  group('Either', () {
    test('Left fold only invokes the failure callback', () {
      const result = Left<String, int>('failure');
      var successInvoked = false;

      final folded = result.fold((failure) => failure.length, (_) {
        successInvoked = true;
        return 0;
      });

      expect(folded, 7);
      expect(successInvoked, isFalse);
      expect(result.isLeft, isTrue);
      expect(result.isRight, isFalse);
    });

    test('Right fold only invokes the success callback', () {
      const result = Right<String, int>(21);
      var failureInvoked = false;

      final folded = result.fold((_) {
        failureInvoked = true;
        return 0;
      }, (value) => value * 2);

      expect(folded, 42);
      expect(failureInvoked, isFalse);
      expect(result.isLeft, isFalse);
      expect(result.isRight, isTrue);
    });

    test('getOrElse lazily returns a fallback only for Left', () {
      const left = Left<String, int>('failure');
      const right = Right<String, int>(42);
      var fallbackCalls = 0;

      int fallback(String _) {
        fallbackCalls++;
        return 7;
      }

      expect(left.getOrElse(fallback), 7);
      expect(right.getOrElse(fallback), 42);
      expect(fallbackCalls, 1);
    });

    test('fold preserves asynchronous callback results', () async {
      const Either<String, int> result = Right(21);

      final folded = result.fold((_) async => 0, (value) async => value * 2);

      await expectLater(folded, completion(42));
    });

    test('branches have value equality and readable representations', () {
      expect(const Left<String, int>('failure'), const Left<String, int>('failure'));
      expect(const Right<String, int>(42), const Right<String, int>(42));
      expect(const Left<String, int>('failure').toString(), 'Left(failure)');
      expect(const Right<String, int>(42).toString(), 'Right(42)');
    });

    test('foldVoid invokes a success callback without a synthetic value', () {
      const Either<String, void> result = Right(null);
      var successInvoked = false;

      result.foldVoid(
        (_) => fail('The failure branch must not be invoked'),
        () => successInvoked = true,
      );

      expect(successInvoked, isTrue);
    });
  });
}
