import 'package:flutter/material.dart';
import 'package:ui_kit/ui_kit.dart';

/// A single item in a [SaDropdown] menu.
///
/// Pair a strongly-typed [value] with the [label] widget that is displayed inside the open menu.
class SaDropdownItem<T> {
  /// Creates a [SaDropdownItem].
  const SaDropdownItem({
    required this.value,
    required this.label,
    this.semanticLabel,
    this.enabled = true,
  });

  /// The typed value this item represents.
  final T value;

  /// The widget rendered inside the dropdown menu row.
  final Widget label;

  /// Text representation of this item.
  final String? semanticLabel;

  /// Whether the item can be selected.
  ///
  /// Disabled items are shown but cannot be tapped.
  final bool enabled;

  /// The text used for accessibility and semantics.
  String get effectiveSemanticLabel {
    final semanticLabel = this.semanticLabel;

    if (semanticLabel != null) {
      return semanticLabel;
    }

    final label = this.label;

    if (label is Text && label.data != null) {
      return label.data!;
    }

    throw ArgumentError(
      'SaDropdownItem.semanticLabel must be provided when label '
      'is not a Text widget.',
    );
  }
}

/// A generic, customizable dropdown built on top of [DropdownMenuFormField].
///
/// Supports any value type [T] via [SaDropdownItem]. Visual properties can be
/// overridden while the widget automatically falls back to the ambient
/// [InputDecorationTheme] — the same theme that [SaTextField] inherits — so
/// the two fields remain visually consistent by default.
class SaDropdown<T> extends StatelessWidget {
  /// Creates a [SaDropdown] widget.
  const SaDropdown({
    required this.items,
    super.key,
    this.value,
    this.onChanged,
    this.decoration,
    this.hintText,
    this.labelText,
    this.errorText,
    this.prefixIcon,
    this.icon,
    this.iconSize = 24.0,
    this.iconEnabledColor,
    this.iconDisabledColor,
    this.dropdownColor,
    this.filled,
    this.fillColor,
    this.enabled = true,
    this.contentPadding,
    this.borderRadius,
    this.menuMaxHeight,
    this.isExpanded = true,
    this.style,
    this.focusNode,
    this.onSaved,
    this.validator,
    this.autovalidateMode = AutovalidateMode.disabled,
  });

  /// The list of selectable items shown in the dropdown menu.
  final List<SaDropdownItem<T>> items;

  /// The currently selected value.
  ///
  /// Must be `null` or equal to one of the [items] values.
  final T? value;

  /// Called whenever the user selects a different item.
  ///
  /// Pass `null` to make the dropdown read-only.
  final ValueChanged<T?>? onChanged;

  /// Full [InputDecoration] override.
  final InputDecoration? decoration;

  /// Placeholder text shown when no value is selected.
  final String? hintText;

  /// Floating label text shown above the field.
  final String? labelText;

  /// Error message rendered below the field.
  ///
  /// Setting this also switches the field into its error state.
  final String? errorText;

  /// An optional widget placed before the selected value.
  final Widget? prefixIcon;

  /// Custom widget used as the trailing dropdown arrow icon.
  ///
  /// Defaults to a HugeIcon chevron when `null`.
  final Widget? icon;

  /// Size of the trailing [icon]. Defaults to `24`.
  final double iconSize;

  /// Color of the trailing icon when the dropdown is enabled.
  final Color? iconEnabledColor;

  /// Color of the trailing icon when the dropdown is disabled.
  final Color? iconDisabledColor;

  /// Background color of the open dropdown overlay.
  ///
  /// Defaults to the surface color from the current theme.
  final Color? dropdownColor;

  /// Whether the field background is filled with [fillColor].
  final bool? filled;

  /// Fill color when [filled] is `true`.
  final Color? fillColor;

  /// Whether this dropdown accepts user interaction.
  ///
  /// Defaults to `true`.
  final bool enabled;

  /// Padding between the decoration border and the selected value.
  final EdgeInsetsGeometry? contentPadding;

  /// Corner radius of the open dropdown overlay.
  final BorderRadius? borderRadius;

  /// Maximum height of the open dropdown overlay.
  final double? menuMaxHeight;

  /// Whether the field expands to fill the available horizontal space.
  ///
  /// Defaults to `true`.
  final bool isExpanded;

  /// Text style applied to the selected value.
  ///
  /// Defaults to [AppTextStyle.bodyL].
  final TextStyle? style;

  /// Focus node for keyboard/accessibility control.
  final FocusNode? focusNode;

  /// Called when the form owning this field is saved.
  final FormFieldSetter<T>? onSaved;

  /// Validates the current value; return a non-null string to show an error.
  final FormFieldValidator<T>? validator;

  /// When to auto-validate the field.
  final AutovalidateMode autovalidateMode;

  bool get _isInteractive => enabled && onChanged != null;

  @override
  Widget build(BuildContext context) {
    final trailingIcon =
        icon ??
        SaIcon(
          icon: const SaIconSource.material(
            Icons.keyboard_arrow_down_rounded,
          ),
          size: iconSize,
          color: _effectiveIconColor(context),
        );
    const trailingAnimationDuration = Duration(milliseconds: 200);

    return DropdownMenuFormField<T>(
      initialSelection: value,
      enabled: _isInteractive,
      menuHeight: menuMaxHeight,
      leadingIcon: prefixIcon,
      trailingIcon: AnimatedRotation(
        turns: 0,
        duration: trailingAnimationDuration,
        child: trailingIcon,
      ),
      selectedTrailingIcon: AnimatedRotation(
        turns: 0.5,
        duration: trailingAnimationDuration,
        child: trailingIcon,
      ),
      requestFocusOnTap: false,
      hintText: decoration == null ? hintText : null,
      label: decoration == null && labelText != null ? Text(labelText!) : null,
      textStyle:
          style ??
          AppTextStyle.bodyL.copyWith(
            color: context.colors.onSurface,
          ),
      inputDecorationTheme: _buildInputDecorationTheme(context),
      decorationBuilder: _buildDecoration,
      menuStyle: _buildMenuStyle(context),
      focusNode: focusNode,
      selectOnly: true,
      enableSearch: false,
      expandedInsets: isExpanded ? EdgeInsets.zero : null,
      dropdownMenuEntries: items
          .map(
            (item) => DropdownMenuEntry<T>(
              value: item.value,
              label: item.effectiveSemanticLabel,
              labelWidget: item.label,
              enabled: item.enabled,
            ),
          )
          .toList(),

      onSelected: _isInteractive ? onChanged : null,
      onSaved: onSaved,
      validator: validator,
      autovalidateMode: autovalidateMode,
      forceErrorText: errorText,
    );
  }

  Color? _effectiveIconColor(BuildContext context) =>
      _isInteractive ? iconEnabledColor : iconDisabledColor;

  InputDecoration _buildDecoration(
    BuildContext context,
    MenuController menuController,
  ) {
    return decoration ??
        InputDecoration(
          filled: filled,
          fillColor: fillColor,
          contentPadding:
              contentPadding ??
              const EdgeInsets.symmetric(
                horizontal: AppSpacing.s,
              ),
        );
  }

  InputDecorationThemeData _buildInputDecorationTheme(BuildContext context) {
    final ambientTheme = Theme.of(context).inputDecorationTheme;

    return ambientTheme.copyWith(
      filled: filled ?? ambientTheme.filled,
      fillColor: fillColor ?? ambientTheme.fillColor,
      contentPadding: contentPadding ?? ambientTheme.contentPadding,
    );
  }

  MenuStyle _buildMenuStyle(BuildContext context) {
    return MenuStyle(
      backgroundColor: WidgetStatePropertyAll(
        dropdownColor ?? context.colors.surface,
      ),
      shape: WidgetStatePropertyAll(
        RoundedRectangleBorder(
          borderRadius: borderRadius ?? BorderRadius.circular(AppRadius.l),
        ),
      ),
    );
  }
}
