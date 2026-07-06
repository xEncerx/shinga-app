import 'package:shinga/data/data.dart';
import 'package:shinga/features/features.dart';
import 'package:storage/storage.dart';

part 'hive_adapters.g.dart';

@GenerateAdapters([
  AdapterSpec<SessionDTO>(),
  AdapterSpec<UserDTO>(),
  AdapterSpec<UserRoleDTO>(),
  AdapterSpec<TitleSearchHistoryItemDTO>(),
  AdapterSpec<AppSettingsDTO>(),
])
/// This file is used to generate Hive TypeAdapters for the specified DTO classes.
// ignore: unused_element
void _() {}
