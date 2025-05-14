import 'package:flutter/material.dart';

class SwitchSettingsTile extends StatelessWidget {
  const SwitchSettingsTile({
    super.key,
    required this.title,
    required this.value,
    required this.onChanged,
    this.subTitle,
    this.leadingIcon,
  });

  final String title;
  final String? subTitle;
  final IconData? leadingIcon;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(
        title,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: subTitle != null
          ? Text(
              subTitle!,
              overflow: TextOverflow.ellipsis,
            )
          : null,
      leading: leadingIcon != null
          ? Icon(
              leadingIcon,
              size: 30,
            )
          : null,
      trailing: Switch(value: value, onChanged: onChanged),
    );
  }
}
