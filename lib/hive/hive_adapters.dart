import 'package:hive_ce/hive.dart';
import '../data/models/models.dart';

@GenerateAdapters([
  AdapterSpec<SearchHistoryItem>(),
  AdapterSpec<AppSettings>(),
])
part 'hive_adapters.g.dart';
