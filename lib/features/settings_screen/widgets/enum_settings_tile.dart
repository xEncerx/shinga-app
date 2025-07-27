import 'package:auto_route/auto_route.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class EnumSettingsTile<T extends Enum> extends StatelessWidget {
  const EnumSettingsTile({
    super.key,
    required this.title,
    this.prefixIcon,
    required this.currentValue,
    required this.values,
    required this.onSelected,
  });

  final String title;
  final IconData? prefixIcon;
  final T currentValue;
  final List<T> values;
  final void Function(T) onSelected;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(title),
      subtitle: Text(describeEnum(currentValue)),
      leading: prefixIcon != null ? Icon(prefixIcon) : null,
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
