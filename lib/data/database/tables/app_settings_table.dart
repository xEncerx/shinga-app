part of '../app_database.dart';

/// Stores the single application settings snapshot.
@DataClassName('AppSettingsRow')
class AppSettingsTable extends Table {
  /// The singleton row identifier.
  IntColumn get id => integer()();

  /// The preferred reader implementation.
  TextColumn get readMode => text()();

  /// The preferred title presentation style.
  TextColumn get titleButtonStyle => text()();

  /// The preferred application theme mode.
  TextColumn get themeMode => text()();

  /// The preferred application color scheme.
  TextColumn get colorScheme => text()();

  /// The preferred application language.
  TextColumn get language => text()();

  /// Whether request blocking is enabled in the reader.
  BoolColumn get isAdBlockerEnabled => boolean()();

  @override
  String get tableName => 'app_settings';

  @override
  Set<Column<Object>> get primaryKey => {id};

  @override
  List<String> get customConstraints => ['CHECK (id = 1)'];
}
