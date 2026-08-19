part of '../app_database.dart';

/// A complete persisted settings snapshot with ordered filter URLs.
final class StoredAppSettings {
  /// Creates a persisted settings snapshot.
  const StoredAppSettings({
    required this.settings,
    required this.filterSubscriptionUrls,
  });

  /// The scalar settings row.
  final AppSettingsRow settings;

  /// Filter-list URLs in their persisted order.
  final List<String> filterSubscriptionUrls;
}

/// Provides transactional access to application settings.
@DriftAccessor(tables: [AppSettingsTable, AdBlockerFilterSubscriptionsTable])
final class AppSettingsDao extends DatabaseAccessor<AppDatabase> with _$AppSettingsDaoMixin {
  /// Creates a DAO attached to its database.
  AppSettingsDao(super.attachedDatabase);

  static const _settingsId = 1;

  /// Returns the persisted settings snapshot, or `null` when absent.
  Future<StoredAppSettings?> getSettings() => _settingsQuery().get().then(_mapRows);

  /// Emits the current settings snapshot and every committed change.
  Stream<StoredAppSettings?> watchSettings() => _settingsQuery().watch().map(_mapRows);

  /// Replaces scalar settings and ordered subscriptions atomically.
  Future<void> saveSettings({
    required AppSettingsTableCompanion settings,
    required List<String> filterSubscriptionUrls,
  }) {
    return transaction(() async {
      await into(appSettingsTable).insertOnConflictUpdate(settings);
      await (delete(
        adBlockerFilterSubscriptionsTable,
      )..where((row) => row.settingsId.equals(_settingsId))).go();

      if (filterSubscriptionUrls.isEmpty) return;

      await batch((batch) {
        batch.insertAll(
          adBlockerFilterSubscriptionsTable,
          [
            for (final (position, url) in filterSubscriptionUrls.indexed)
              AdBlockerFilterSubscriptionsTableCompanion.insert(
                settingsId: _settingsId,
                position: position,
                url: url,
              ),
          ],
        );
      });
    });
  }

  /// Updates a settings snapshot inside a single database transaction.
  Future<void> updateSettings(
    StoredAppSettings Function(StoredAppSettings? current) update,
  ) {
    return transaction(() async {
      final updated = update(await getSettings());
      await saveSettings(
        settings: updated.settings.toCompanion(true),
        filterSubscriptionUrls: updated.filterSubscriptionUrls,
      );
    });
  }

  JoinedSelectStatement<HasResultSet, dynamic> _settingsQuery() {
    return select(appSettingsTable).join([
        leftOuterJoin(
          adBlockerFilterSubscriptionsTable,
          adBlockerFilterSubscriptionsTable.settingsId.equalsExp(appSettingsTable.id),
        ),
      ])
      ..where(appSettingsTable.id.equals(_settingsId))
      ..orderBy([
        OrderingTerm.asc(adBlockerFilterSubscriptionsTable.position),
      ]);
  }

  StoredAppSettings? _mapRows(List<TypedResult> rows) {
    if (rows.isEmpty) return null;

    return StoredAppSettings(
      settings: rows.first.readTable(appSettingsTable),
      filterSubscriptionUrls: [
        for (final row in rows)
          if (row.readTableOrNull(adBlockerFilterSubscriptionsTable) case final subscription?)
            subscription.url,
      ],
    );
  }
}
