import 'package:flutter/material.dart';

import '../../../core/core.dart';

/// A ListTile that contains a switch to toggle a boolean setting.
class SwitchSettingsTile extends StatelessWidget {
  const SwitchSettingsTile({
    super.key,
    required this.title,
    required this.value,
    required this.onChanged,
    this.subTitle,
    this.prefixIcon,
    this.prefixWidget,
  });

  /// The title of the settings tile.
  final String title;

  /// An optional subtitle for additional context.
  final String? subTitle;

  /// An optional icon to display before the title.
  final Object? prefixIcon;

  /// An optional widget to display before the title.
  final Widget? prefixWidget;

  /// The current value of the switch.
  final bool value;

  /// Callback when the switch value changes.
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
      secondary: prefixIcon != null ? IconContainer(icon: prefixIcon!) : prefixWidget,
    );
  }
}
