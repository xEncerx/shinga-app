import 'dart:async';

var _invocationState = 0;

/// Returns the invocation parameters unchanged.
Future<Object?> echo(Object? params) async => params;

/// Increments isolated mutable state to expose cross-invocation reuse.
int stateIsolation(Object? params) {
  return ++_invocationState;
}

/// Exercises synchronous and concurrent asynchronous host calls.
Future<List<Object?>> hostFlow(Object? params) async {
  final input = (params as Map<String, Object?>?)!;
  final first = await _context.call('fixture.sync', input['value']);
  final concurrent = await Future.wait<Object?>([
    _context.call('fixture.async', first),
    _context.call('fixture.async', input['value']),
  ]);
  return [first, ...concurrent];
}

/// Converts a structured host rejection into fixture-visible JSON.
Future<Object?> hostRejection(Object? params) async {
  try {
    return await _context.call('fixture.reject', params);
  } on _HostCallRejected catch (error) {
    return {'category': error.category, 'code': error.code};
  }
}

/// Leaves one cancellable host operation pending for lifecycle tests.
Future<Object?> cancellableHostCall(Object? params) {
  return _context.call('fixture.cancellable', params);
}

/// Runs an unbounded while loop for execution-limit tests.
Never infiniteWhile(Object? params) {
  while (true) {}
}

/// Runs an unbounded for loop for execution-limit tests.
Never infiniteFor(Object? params) {
  for (;;) {}
}

/// Recurses without a base case for execution-limit tests.
Object? infiniteRecursion(Object? params) {
  return infiniteRecursion(params);
}

final _context = _FixtureContext();

final class _FixtureContext {
  Future<Object?> call(String operation, Object? payload) async {
    final response = (await _hostCall(operation, payload) as Map<Object?, Object?>?)!;
    final error = response['error'];
    if (error is Map<Object?, Object?>) {
      throw _HostCallRejected(
        (error['category'] as String?)!,
        (error['code'] as String?)!,
      );
    }
    return response['result'];
  }
}

Future<Object?> _hostCall(String operation, Object? payload) {
  // D4rt injects this single native transport only inside the worker isolate.
  // ignore: undefined_function
  return __shingaHostCall(operation, payload) as Future<Object?>;
}

final class _HostCallRejected implements Exception {
  _HostCallRejected(this.category, this.code);

  final String category;
  final String code;
}
