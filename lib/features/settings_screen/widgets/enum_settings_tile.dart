import 'package:auto_route/auto_route.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../../core/core.dart';

/// A settings tile that allows users to select from a list of enum values.
class EnumSettingsTile<T extends Enum> extends StatelessWidget {
  const EnumSettingsTile({
    super.key,
    required this.title,
    required this.currentValue,
    required this.values,
    required this.onSelected,
    this.prefixIcon,
    this.prefixWidget,
  });

  /// The title of the settings tile.
  final String title;

  /// An optional icon to display before the title.
  final Object? prefixIcon;

  /// An optional widget to display before the title.
  final Widget? prefixWidget;

  /// Current selected enum value.
  final T currentValue;

  /// The list of enum values to choose from.
  final List<T> values;

  /// Callback when a new value is selected.
  final void Function(T) onSelected;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(title),
      subtitle: Text(describeEnum(currentValue)),
      leading: prefixIcon != null ? IconContainer(icon: prefixIcon!) : prefixWidget,
      trailing: const Icon(Icons.keyboard_arrow_down_rounded),
      onTap: () {
        showDialog<T>(
          context: context,
          builder: (context) {
            return SimpleDialog(
              title: Text(title),
              children: values.map((T value) {
                return SimpleDialogOption(
                  onPressed: () {
                    context.router.pop();
                    onSelected(value);
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(describeEnum(value)),
                      if (value == currentValue) const Icon(Icons.check_rounded),
                    ],
                  ),
                );
              }).toList(),
            );
          },
        );
      },
    );
  }
}
