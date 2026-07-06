import 'package:flutter/material.dart';
import 'package:ui_kit/ui_kit.dart';

/// A styled list tile that opens an enum-value picker dialog on tap.
///
/// Tapping the tile presents a dialog listing all [values]. The currently
/// selected [value] is indicated by a [checkIcon] next to its label.
class SaEnumPickerTile<T extends Enum> extends StatelessWidget {
  /// Creates a [SaEnumPickerTile].
  const SaEnumPickerTile({
    required this.values,
    required this.labelBuilder,
    this.value,
    this.onChanged,
    this.leading,
    this.title,
    this.subtitle,
    this.trailing,
    this.contentPadding,
    this.tileColor,
    this.borderRadius,
    this.enabled = true,
    this.constraints,
    this.dialogTitle,
    this.cancelLabel,
    this.checkIcon,
    this.checkIconColor,
    super.key,
  });

  /// All possible enum values to display in the dialog.
  final List<T> values;

  /// Converts an enum value to a display label.
  final String Function(T) labelBuilder;

  /// Currently selected value.
  final T? value;

  /// Called when the user selects a new value from the dialog.
  final ValueChanged<T>? onChanged;

  /// Widget placed at the start of the tile.
  final Widget? leading;

  /// Primary content of the tile.
  final Widget? title;

  /// Additional content displayed below [title].
  final Widget? subtitle;

  /// Widget placed at the end of the tile.
  final Widget? trailing;

  /// Padding around the tile content.
  ///
  /// Defaults to horizontal [AppSpacing.m].
  final EdgeInsetsGeometry? contentPadding;

  /// Corner radius of the tile.
  ///
  /// Defaults to [AppRadius.card].
  final double? borderRadius;

  /// Whether the tile is interactive.
  final bool enabled;

  /// Fill color of the tile background.
  ///
  /// Defaults to primary theme color at 20 % opacity.
  final Color? tileColor;

  /// Constraints applied to the tile.
  final BoxConstraints? constraints;

  /// Title widget displayed at the top of the picker dialog.
  final Widget? dialogTitle;

  /// Label for the cancel button in the picker dialog.
  ///
  /// Defaults to `"Cancel"`.
  final String? cancelLabel;

  /// Icon shown next to the selected value in the picker dialog.
  ///
  /// Defaults to [Icons.check_rounded].
  final IconData? checkIcon;

  /// Color of the [checkIcon].
  ///
  /// Defaults to the primary color of the current [ColorScheme].
  final Color? checkIconColor;

  Future<void> _showPicker(BuildContext context) async {
    final selected = await showDialog<T>(
      context: context,
      builder: (_) => _EnumPickerDialog<T>(
        values: values,
        labelBuilder: labelBuilder,
        selected: value,
        dialogTitle: dialogTitle,
        cancelLabel: cancelLabel,
        checkIcon: checkIcon ?? Icons.check_rounded,
        checkIconColor: checkIconColor,
      ),
    );
    if (selected != null) {
      onChanged?.call(selected);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SaListTile(
      leading: leading,
      title: title,
      subtitle:
          subtitle ??
          (value != null
              ? SaText(
                  labelBuilder(value!),
                )
              : null),
      trailing:
          trailing ?? const SaIcon(icon: SaIconSource.huge(HugeIconsStrokeRounded.arrowRight01)),
      contentPadding: contentPadding,
      tileColor: tileColor,
      borderRadius: borderRadius,
      enabled: enabled,
      constraints: constraints,
      onTap: () => _showPicker(context),
    );
  }
}

class _EnumPickerDialog<T extends Enum> extends StatelessWidget {
  const _EnumPickerDialog({
    required this.values,
    required this.labelBuilder,
    required this.checkIcon,
    this.selected,
    this.dialogTitle,
    this.cancelLabel,
    this.checkIconColor,
  });

  final List<T> values;
  final String Function(T) labelBuilder;
  final T? selected;
  final Widget? dialogTitle;
  final String? cancelLabel;
  final IconData checkIcon;
  final Color? checkIconColor;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colors;
    final effectiveCheckColor = checkIconColor ?? colorScheme.primary;

    return SaAppDialog(
      title: dialogTitle,
      contentPadding: const EdgeInsets.only(top: AppSpacing.s),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final item in values)
              InkWell(
                onTap: () => Navigator.of(context).pop(item),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.xl,
                    vertical: AppSpacing.m,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: SaText(
                          labelBuilder(item),
                          style: AppTextStyle.bodyL,
                        ),
                      ),
                      if (selected == item)
                        SaIcon(
                          icon: const SaIconSource.material(Icons.check_rounded),
                          color: effectiveCheckColor,
                          size: 20,
                        ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
      actions: [
        if (cancelLabel != null)
          SaTextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: SaText(cancelLabel!),
          ),
      ],
    );
  }
}
