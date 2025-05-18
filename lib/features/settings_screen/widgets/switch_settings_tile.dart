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
    return SwitchListTile(
      value: value,
      visualDensity: VisualDensity.compact,
      onChanged: onChanged,
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
      secondary: leadingIcon != null
          ? Icon(
              leadingIcon,
              size: 28,
            )
          : null,
    );
  }
}
