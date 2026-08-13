import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shinga/core/types/types.dart';
import 'package:shinga/domain/domain.dart';
import 'package:shinga/features/features.dart';
import 'package:talker/talker.dart';

final class _MockAuthRepository extends Mock implements AuthRepository;

final class _MockSessionRepository extends Mock implements SessionRepository;

void main() {
  late _MockAuthRepository authRepository;
  late _MockSessionRepository sessionRepository;
  late Talker logger;

  const session = Session(
    user: UserEntity(
      id: 1,
      username: 'reader',
      email: 'reader@example.com',
      avatarUrl: '/avatar.png',
      role: UserRole.user,
    ),
  );

  setUp(() {
    authRepository = _MockAuthRepository();
    sessionRepository = _MockSessionRepository();
    logger = Talker();
  });

  blocTest<SessionBloc, SessionState>(
    'emits unauthenticated from the initial database snapshot',
    setUp: () {
      when(sessionRepository.watchSession).thenAnswer((_) => Stream.value(null));
    },
    build: () => SessionBloc(
      authRepository: authRepository,
      sessionRepository: sessionRepository,
      logger: logger,
    ),
    expect: () => [isA<SessionUnauthenticated>()],
    verify: (_) {
      verify(sessionRepository.watchSession).called(1);
      verifyNever(sessionRepository.getSession);
      verifyNever(authRepository.refreshSession);
    },
  );

  blocTest<SessionBloc, SessionState>(
    'refreshes an authenticated initial database snapshot once',
    setUp: () {
      when(sessionRepository.watchSession).thenAnswer(
        (_) => Stream.fromIterable([session, session]),
      );
      when(authRepository.refreshSession).thenAnswer((_) async => const Right(null));
    },
    build: () => SessionBloc(
      authRepository: authRepository,
      sessionRepository: sessionRepository,
      logger: logger,
    ),
    expect: () => [isA<SessionAuthenticated>()],
    verify: (_) {
      verify(authRepository.refreshSession).called(1);
    },
  );
}
