import 'package:flutter/material.dart';
import 'package:ui_kit/ui_kit.dart';

/// A single item in a [SaDropdown] menu.
///
/// Pair a strongly-typed [value] with the [label] widget that is displayed
/// both in the open menu and (unless selectedItemBuilder is set on
/// [SaDropdown]) as the selected-state display.
class SaDropdownItem<T> {
  /// Creates a [SaDropdownItem].
  const SaDropdownItem({
    required this.value,
    required this.label,
    this.enabled = true,
  });

  /// The typed value this item represents.
  final T value;

  /// The widget rendered inside the dropdown menu row.
  final Widget label;

  /// Whether the item can be selected.
  ///
  /// Disabled items are shown but cannot be tapped.
  final bool enabled;
}

/// A generic, customizable dropdown built on top of [DropdownButtonFormField].
///
/// Supports any value type [T] via [SaDropdownItem]. All visual properties
/// (decoration, padding, icon, colors …) can be overridden while the widget
/// automatically falls back to the ambient [InputDecoration] theme — the same
/// theme that [SaTextField] inherits — so the two fields look identical by
/// default.
class SaDropdown<T> extends StatefulWidget {
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
    this.itemHeight = kMinInteractiveDimension,
    this.isExpanded = true,
    this.isDense = false,
    this.style,
    this.focusNode,
    this.selectedItemBuilder,
    this.onSaved,
    this.validator,
    this.autovalidateMode,
    this.alignment = AlignmentDirectional.centerStart,
  });

  /// The list of selectable items shown in the dropdown menu.
  final List<SaDropdownItem<T>> items;

  /// The currently selected value.
  ///
  /// Must be `null` or equal to one of the [items] values.
  final T? value;

  /// Called whenever the user selects a different item.
  ///
  /// Pass `null` to make the dropdown read-only (disabled interaction).
  final ValueChanged<T?>? onChanged;

  /// Full [InputDecoration] override.
  final InputDecoration? decoration;

  /// Placeholder text shown when no value is selected.
  final String? hintText;

  /// Floating label text shown above the field.
  final String? labelText;

  /// Error message rendered below the field.
  ///
  /// Setting this also switches the border to the error color.
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

  /// Whether this dropdown accepts user interaction. Defaults to `true`.
  final bool enabled;

  /// Padding between the decoration border and the selected value widget.
  final EdgeInsetsGeometry? contentPadding;

  /// Corner radius of the open dropdown overlay.
  final BorderRadius? borderRadius;

  /// Maximum height of the open dropdown overlay.
  final double? menuMaxHeight;

  /// Height of each item row inside the open dropdown. Defaults to
  /// [kMinInteractiveDimension] (`48`).
  final double? itemHeight;

  /// Whether the button hint / selected value expands to fill available
  /// horizontal space. Defaults to `true`.
  final bool isExpanded;

  /// Whether the button uses a smaller, denser layout.
  final bool isDense;

  /// Text style applied to the selected value.
  ///
  /// Defaults to [AppTextStyle.bodyL].
  final TextStyle? style;

  /// Focus node for keyboard/accessibility control.
  final FocusNode? focusNode;

  /// Builder allowing a different widget to be shown for a selected item
  /// compared to the open-menu representation.
  final DropdownButtonBuilder? selectedItemBuilder;

  /// Called when the form owning this field is saved.
  final FormFieldSetter<T>? onSaved;

  /// Validates the current value; return a non-null string to show an error.
  final FormFieldValidator<T>? validator;

  /// When to auto-validate the field.
  final AutovalidateMode? autovalidateMode;

  /// Alignment of the selected value within the button. Defaults to
  /// [AlignmentDirectional.centerStart].
  final AlignmentDirectional alignment;

  @override
  State<SaDropdown<T>> createState() => _SaDropdownState<T>();
}

class _SaDropdownState<T> extends State<SaDropdown<T>> {
  late final FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _focusNode = widget.focusNode ?? FocusNode();
  }

  @override
  void dispose() {
    if (widget.focusNode == null) {
      _focusNode.dispose();
    }
    super.dispose();
  }

  InputDecoration _buildDecoration(BuildContext context) {
    if (widget.decoration != null) return widget.decoration!;
    return InputDecoration(
      hintText: widget.hintText,
      labelText: widget.labelText,
      errorText: widget.errorText,
      prefixIcon: widget.prefixIcon,
      filled: widget.filled,
      fillColor: widget.fillColor,
      contentPadding: widget.contentPadding ?? const EdgeInsets.symmetric(horizontal: AppSpacing.s),
    );
  }

  @override
  Widget build(BuildContext context) {
    return TapRegion(
      onTapOutside: (_) => _focusNode.unfocus(),
      child: DropdownButtonFormField<T>(
        initialValue: widget.value,
        focusNode: _focusNode,
        isExpanded: widget.isExpanded,
        isDense: widget.isDense,
        itemHeight: widget.itemHeight,
        menuMaxHeight: widget.menuMaxHeight,
        style: widget.style ?? AppTextStyle.bodyL.copyWith(color: context.colors.onSurface),
        dropdownColor: widget.dropdownColor ?? context.colors.surface,
        borderRadius: widget.borderRadius ?? BorderRadius.circular(AppRadius.l),
        alignment: widget.alignment,
        icon:
            widget.icon ??
            SaIcon(
              icon: const SaIconSource.material(Icons.keyboard_arrow_down_rounded),
              size: widget.iconSize,
            ),
        iconEnabledColor: widget.iconEnabledColor,
        iconDisabledColor: widget.iconDisabledColor,
        decoration: _buildDecoration(context),
        selectedItemBuilder: widget.selectedItemBuilder,
        onChanged: widget.enabled ? widget.onChanged : null,
        onSaved: widget.onSaved,
        validator: widget.validator,
        autovalidateMode: widget.autovalidateMode,
        mouseCursor: widget.enabled ? SystemMouseCursors.click : SystemMouseCursors.forbidden,
        items: widget.items
            .map(
              (item) => DropdownMenuItem<T>(
                value: item.value,
                enabled: item.enabled,
                child: item.label,
              ),
            )
            .toList(),
      ),
    );
  }
}
