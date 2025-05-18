import 'package:hive_ce/hive.dart';

import '../data/models/models.dart';
import '../domain/domain.dart';

@GenerateAdapters([
  AdapterSpec<SearchHistoryItem>(),
  AdapterSpec<AppSettings>(),
  AdapterSpec<MangaSource>()
])
part 'hive_adapters.g.dart';
