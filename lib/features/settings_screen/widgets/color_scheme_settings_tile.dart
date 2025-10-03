import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';

/// A ListTile that allows the user to select a color scheme from a list of available schemes.
class ColorSchemeSettingsTile extends StatelessWidget {
  const ColorSchemeSettingsTile({
    super.key,
    required this.title,
    required this.currentValue,
    required this.values,
    required this.onSelected,
    this.prefixIcon,
  });

  /// The title of the settings tile.
  final String title;

  /// An optional icon to display at the start of the tile.
  final IconData? prefixIcon;

  /// The currently selected color scheme.
  final FlexScheme currentValue;

  /// The list of available color schemes.
  final List<FlexScheme> values;

  /// Callback when a new color scheme is selected.
  final void Function(FlexScheme) onSelected;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(title),
      subtitle: Text(_getSchemeName(currentValue)),
      leading: prefixIcon != null ? Icon(prefixIcon) : null,
      trailing: Container(
        width: 52,
        height: 30,
        margin: const EdgeInsets.only(right: 4),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(4),
          gradient: LinearGradient(
            colors: [
              FlexThemeData.light(scheme: currentValue).colorScheme.primary,
              FlexThemeData.light(scheme: currentValue).colorScheme.secondary,
            ],
          ),
        ),
      ),
      onTap: () => _showSchemeDialog(context),
    );
  }

  void _showSchemeDialog(BuildContext context) {
    showDialog<FlexScheme>(
      context: context,
      builder: (context) {
        return SimpleDialog(
          title: Text(title),
          children: values.map((FlexScheme scheme) {
            return SimpleDialogOption(
              onPressed: () {
                Navigator.of(context).pop();
                onSelected(scheme);
              },
              child: Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    margin: const EdgeInsets.only(right: 16),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      gradient: LinearGradient(
                        colors: [
                          FlexThemeData.light(scheme: scheme).colorScheme.primary,
                          FlexThemeData.light(scheme: scheme).colorScheme.secondary,
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    child: Text(_getSchemeName(scheme)),
                  ),
                  if (scheme == currentValue) const Icon(Icons.check_rounded),
                ],
              ),
            );
          }).toList(),
        );
      },
    );
  }

  String _getSchemeName(FlexScheme scheme) {
    // Возвращаем читаемое имя схемы
    return scheme.name
        .replaceAllMapped(
          RegExp(r'([A-Z])'),
          (match) => ' ${match.group(1)}',
        )
        .trim();
  }
}
