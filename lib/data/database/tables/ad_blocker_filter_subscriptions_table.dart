part of '../app_database.dart';

/// Stores the ordered filter subscriptions belonging to app settings.
@DataClassName('AdBlockerFilterSubscriptionRow')
class AdBlockerFilterSubscriptionsTable extends Table {
  /// References the singleton settings row.
  IntColumn get settingsId => integer().references(
    AppSettingsTable,
    #id,
    onDelete: KeyAction.cascade,
  )();

  /// Preserves the user-defined subscription order.
  IntColumn get position => integer()();

  /// The remote filter-list URL.
  TextColumn get url => text()();

  @override
  String get tableName => 'ad_blocker_filter_subscriptions';

  @override
  Set<Column<Object>> get primaryKey => {settingsId, position};
}
