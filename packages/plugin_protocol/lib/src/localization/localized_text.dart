import 'package:meta/meta.dart';
import 'package:plugin_protocol/src/localization/locale_tag.dart';

/// Text values indexed by normalized locale tags.
@immutable
final class LocalizedText {
  /// Creates localized text from a defensive copy of [values].
  LocalizedText(Map<LocaleTag, String> values) : values = Map.unmodifiable(values);

  /// The localized values in declaration order.
  final Map<LocaleTag, String> values;
}
