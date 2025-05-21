import 'package:hive_ce/hive.dart';

import '../core/core.dart';
import '../data/models/models.dart';

@GenerateAdapters([
  AdapterSpec<SearchHistoryItem>(),
  AdapterSpec<AppSettings>(),
  AdapterSpec<MangaSource>()
])
part 'hive_adapters.g.dart';
