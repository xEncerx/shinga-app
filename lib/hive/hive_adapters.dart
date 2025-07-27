import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';
import 'package:hive_ce/hive.dart';

import '../data/data.dart';
import '../i18n/strings.g.dart';

part 'hive_adapters.g.dart';

@GenerateAdapters([
  AdapterSpec<SearchHistoryItem>(),
  AdapterSpec<FlexScheme>(),
  AdapterSpec<AppSettings>(),
  AdapterSpec<AppLocale>(),
  AdapterSpec<ThemeMode>(),
])
class HiveAdapters {}
