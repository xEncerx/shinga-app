import 'package:flutter/material.dart';

class SwitchSettingsTile extends StatelessWidget {
  const SwitchSettingsTile({
    super.key,
    required this.title,
    required this.value,
    required this.onChanged,
    this.subTitle,
    this.prefixIcon,
  });

  final String title;
  final String? subTitle;
  final IconData? prefixIcon;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return SwitchListTile(
      value: value,
      onChanged: onChanged,
      title: Text(
        title,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: subTitle != null
          ? Text(
              subTitle!,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            )
          : null,
      secondary: prefixIcon != null
          ? Icon(
              prefixIcon,
              size: 28,
            )
          : null,
    );
  }
}
