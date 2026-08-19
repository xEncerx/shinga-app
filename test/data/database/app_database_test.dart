import 'dart:async';

import 'package:drift/drift.dart' hide isNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shinga/data/data.dart';

void main() {
  late AppDatabase database;

  setUp(() {
    database = AppDatabase(
      DatabaseConnection(
        NativeDatabase.memory(),
        closeStreamsSynchronously: true,
      ),
    );
  });

  tearDown(() => database.close());

  group('AppSettingsDao', () {
    test('watches the initial value and committed snapshots', () async {
      final iterator = StreamIterator(database.appSettingsDao.watchSettings());
      expect(await iterator.moveNext(), isTrue);
      expect(iterator.current, isNull);

      await database.appSettingsDao.saveSettings(
        settings: AppSettingsTableCompanion.insert(
          id: const Value(1),
          readMode: 'webView',
          titleButtonStyle: 'card',
          themeMode: 'system',
          colorScheme: 'shadBlue',
          language: 'ru',
          isAdBlockerEnabled: true,
        ),
        filterSubscriptionUrls: const [
          'https://filters.example/a',
          'https://filters.example/a',
        ],
      );

      expect(await iterator.moveNext(), isTrue);
      expect(iterator.current?.settings.language, 'ru');
      expect(iterator.current?.filterSubscriptionUrls, [
        'https://filters.example/a',
        'https://filters.example/a',
      ]);
      await iterator.cancel();
    });

    test('replaces obsolete filter subscriptions', () async {
      final settings = AppSettingsTableCompanion.insert(
        id: const Value(1),
        readMode: 'webView',
        titleButtonStyle: 'card',
        themeMode: 'system',
        colorScheme: 'shadBlue',
        language: 'system',
        isAdBlockerEnabled: false,
      );

      await database.appSettingsDao.saveSettings(
        settings: settings,
        filterSubscriptionUrls: const ['old-a', 'old-b'],
      );
      await database.appSettingsDao.saveSettings(
        settings: settings,
        filterSubscriptionUrls: const ['new'],
      );

      final stored = await database.appSettingsDao.getSettings();
      expect(stored?.filterSubscriptionUrls, ['new']);
    });

    test('updates scalar settings and subscriptions atomically', () async {
      await database.appSettingsDao.saveSettings(
        settings: AppSettingsTableCompanion.insert(
          id: const Value(1),
          readMode: 'webView',
          titleButtonStyle: 'card',
          themeMode: 'system',
          colorScheme: 'shadBlue',
          language: 'system',
          isAdBlockerEnabled: false,
        ),
        filterSubscriptionUrls: const ['old'],
      );

      await database.appSettingsDao.updateSettings(
        (current) => StoredAppSettings(
          settings: current!.settings.copyWith(language: 'en'),
          filterSubscriptionUrls: const ['new'],
        ),
      );

      final stored = await database.appSettingsDao.getSettings();
      expect(stored?.settings.language, 'en');
      expect(stored?.filterSubscriptionUrls, ['new']);
    });
  });

  group('SessionDao', () {
    test('watches sign-in and sign-out after the initial null value', () async {
      final iterator = StreamIterator(database.sessionDao.watchCurrentSession());
      expect(await iterator.moveNext(), isTrue);
      expect(iterator.current, isNull);

      await database.sessionDao.saveCurrentSession(
        CurrentSessionTableCompanion.insert(
          id: const Value(1),
          userId: 42,
          username: 'reader',
          email: 'reader@example.com',
          avatarPath: '/avatar.png',
          role: 'user',
          description: const Value('Manga reader'),
        ),
      );
      expect(await iterator.moveNext(), isTrue);
      expect(iterator.current?.username, 'reader');

      await database.sessionDao.clearCurrentSession();
      expect(await iterator.moveNext(), isTrue);
      expect(iterator.current, isNull);
      await iterator.cancel();
    });
  });

  group('TitleSearchHistoryDao', () {
    test('upserts exact queries and trims the oldest rows', () async {
      final first = DateTime.utc(2026);
      final second = DateTime.utc(2026, 1, 2);
      final third = DateTime.utc(2026, 1, 3);

      await database.titleSearchHistoryDao.saveItem(
        TitleSearchHistoryTableCompanion.insert(
          query: 'One Piece',
          searchedAt: first,
        ),
      );
      await database.titleSearchHistoryDao.saveItem(
        TitleSearchHistoryTableCompanion.insert(
          query: 'one piece',
          searchedAt: second,
        ),
      );
      await database.titleSearchHistoryDao.saveItem(
        TitleSearchHistoryTableCompanion.insert(
          query: 'One Piece',
          searchedAt: third,
        ),
        maxItems: 1,
      );

      final history = await database.titleSearchHistoryDao.getHistory();
      expect(history.map((row) => row.query), ['One Piece']);
      expect(history.single.searchedAt, third);
    });

    test('uses the query as a deterministic timestamp tie-breaker', () async {
      final searchedAt = DateTime.utc(2026);
      for (final query in ['B', 'A']) {
        await database.titleSearchHistoryDao.saveItem(
          TitleSearchHistoryTableCompanion.insert(
            query: query,
            searchedAt: searchedAt,
          ),
        );
      }

      final history = await database.titleSearchHistoryDao.getHistory();
      expect(history.map((row) => row.query), ['A', 'B']);
    });
  });
}
