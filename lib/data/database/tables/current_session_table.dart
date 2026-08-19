part of '../app_database.dart';

/// Stores the single authenticated user snapshot.
@DataClassName('CurrentSessionRow')
class CurrentSessionTable extends Table {
  /// The singleton row identifier.
  IntColumn get id => integer()();

  /// The authenticated user's server identifier.
  IntColumn get userId => integer()();

  /// The authenticated user's display name.
  TextColumn get username => text()();

  /// The authenticated user's email address.
  TextColumn get email => text()();

  /// The authenticated user's avatar path.
  TextColumn get avatarPath => text()();

  /// The authenticated user's role name.
  TextColumn get role => text()();

  /// The authenticated user's optional description.
  TextColumn get description => text().nullable()();

  @override
  String get tableName => 'current_session';

  @override
  Set<Column<Object>> get primaryKey => {id};

  @override
  List<String> get customConstraints => ['CHECK (id = 1)'];
}
