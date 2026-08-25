import 'package:meta/meta.dart';
import 'package:plugin_protocol/src/localization/localized_text.dart';

/// A user-configurable setting declared by a plugin manifest.
@immutable
sealed class PluginSettingDefinition {
  /// Creates the common part of a plugin setting definition.
  const PluginSettingDefinition({
    required this.id,
    required this.label,
    required this.required,
    this.description,
  });

  /// The identifier exposed through the plugin settings API.
  final String id;

  /// The user-facing setting label.
  final LocalizedText label;

  /// Whether the user must provide a value.
  final bool required;

  /// The optional localized Markdown explaining why this setting is needed.
  final LocalizedText? description;
}

/// A plain text setting.
final class TextPluginSettingDefinition extends PluginSettingDefinition {
  /// Creates a plain text setting definition.
  const TextPluginSettingDefinition({
    required super.id,
    required super.label,
    required super.required,
    required this.defaultValue,
    super.description,
  });

  /// The optional initial text value.
  final String? defaultValue;
}

/// A sensitive text setting without a manifest-provided default.
final class SecretPluginSettingDefinition extends PluginSettingDefinition {
  /// Creates a secret setting definition.
  const SecretPluginSettingDefinition({
    required super.id,
    required super.label,
    required super.required,
    super.description,
  });
}

/// A boolean setting.
final class BooleanPluginSettingDefinition extends PluginSettingDefinition {
  /// Creates a boolean setting definition.
  const BooleanPluginSettingDefinition({
    required super.id,
    required super.label,
    required super.required,
    required this.defaultValue,
    super.description,
  });

  /// The initial boolean value.
  final bool defaultValue;
}

/// A numeric setting.
final class NumberPluginSettingDefinition extends PluginSettingDefinition {
  /// Creates a numeric setting definition.
  const NumberPluginSettingDefinition({
    required super.id,
    required super.label,
    required super.required,
    required this.defaultValue,
    super.description,
  });

  /// The optional finite initial number.
  final num? defaultValue;
}

/// A labeled value available to selection settings.
@immutable
final class PluginSettingOption {
  /// Creates a setting option.
  const PluginSettingOption({required this.value, required this.label});

  /// The value exposed through the plugin settings API.
  final String value;

  /// The user-facing option label.
  final LocalizedText label;
}

/// A setting that accepts one value from a fixed option list.
final class SelectPluginSettingDefinition extends PluginSettingDefinition {
  /// Creates a single-select setting definition.
  SelectPluginSettingDefinition({
    required super.id,
    required super.label,
    required super.required,
    required List<PluginSettingOption> options,
    required this.defaultValue,
    super.description,
  }) : options = List.unmodifiable(options);

  /// The available options in declaration order.
  final List<PluginSettingOption> options;

  /// The optional initial option value.
  final String? defaultValue;
}

/// A setting that accepts multiple values from a fixed option list.
final class MultiSelectPluginSettingDefinition extends PluginSettingDefinition {
  /// Creates a multi-select setting definition.
  MultiSelectPluginSettingDefinition({
    required super.id,
    required super.label,
    required super.required,
    required List<PluginSettingOption> options,
    required List<String>? defaultValue,
    super.description,
  }) : options = List.unmodifiable(options),
       defaultValue = defaultValue == null ? null : List.unmodifiable(defaultValue);

  /// The available options in declaration order.
  final List<PluginSettingOption> options;

  /// The optional initial option values.
  final List<String>? defaultValue;
}
