import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:path_provider/path_provider.dart';

part 'app_database.g.dart';
part 'daos/app_settings_dao.dart';
part 'daos/session_dao.dart';
part 'daos/title_search_history_dao.dart';
part 'tables/ad_blocker_filter_subscriptions_table.dart';
part 'tables/app_settings_table.dart';
part 'tables/current_session_table.dart';
part 'tables/title_search_history_table.dart';

/// The application's persistent SQLite database.
///
/// Keeps durable application data separate from disposable HTTP cache data.
@DriftDatabase(
  tables: [
    AppSettingsTable,
    AdBlockerFilterSubscriptionsTable,
    CurrentSessionTable,
    TitleSearchHistoryTable,
  ],
  daos: [AppSettingsDao, SessionDao, TitleSearchHistoryDao],
)
final class AppDatabase extends _$AppDatabase {
  /// Creates the database with an optional executor for tests.
  AppDatabase([QueryExecutor? executor]) : super(executor ?? _openConnection());

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (migrator) => migrator.createAll(),
    beforeOpen: (_) => customStatement('PRAGMA foreign_keys = ON'),
  );

  static QueryExecutor _openConnection() => driftDatabase(
    name: 'shinga',
    native: DriftNativeOptions(
      databaseDirectory: () async {
        final supportDirectory = await getApplicationSupportDirectory();
        final databaseDirectory = Directory.fromUri(
          supportDirectory.uri.resolve('shinga/database/'),
        );
        await databaseDirectory.create(recursive: true);
        return databaseDirectory;
      },
    ),
  );
}
