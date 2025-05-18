import 'package:flutter/material.dart';

class DropdownSettingsTile<T> extends StatelessWidget {
  const DropdownSettingsTile({
    super.key,
    required this.title,
    this.subTitle,
    required this.leadingIcon,
    required this.value,
    required this.items,
    required this.itemLabelBuilder,
    required this.onChanged,
  });

  final String title;
  final String? subTitle;
  final IconData leadingIcon;
  final T value;
  final List<T> items;
  final String Function(T) itemLabelBuilder;
  final void Function(T?) onChanged;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(leadingIcon, size: 28),
      visualDensity: VisualDensity.compact,
      title: Text(
        title,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: subTitle != null ? Text(subTitle!) : null,
      trailing: DropdownButton<T>(
        value: value,
        onChanged: onChanged,
        underline: const SizedBox(),
        dropdownColor: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: BorderRadius.circular(10),
        items: items.map<DropdownMenuItem<T>>((T item) {
          return DropdownMenuItem<T>(
            value: item,
            child: Text(itemLabelBuilder(item)),
          );
        }).toList(),
      ),
    );
  }
}
