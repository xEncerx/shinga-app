import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';

/// A custom FormBuilderListTile widget that integrates with FormBuilder
/// to create a list tile that can be used in forms.
class FormBuilderListTile extends StatelessWidget {
  const FormBuilderListTile({
    super.key,
    required this.name,
    required this.title,
    required this.onTap,
  });

  /// The name of the field in the FormBuilder.
  final String name;

  /// The title to display on the list tile.
  final String title;

  /// The callback function to call when the list tile is tapped.
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return FormBuilderField<List<String>>(
      name: name,
      builder: (_) {
        return ListTile(
          title: Text(title),
          contentPadding: EdgeInsets.zero,
          trailing: const Icon(
            Icons.arrow_forward_ios_rounded,
            size: 18,
          ),
          onTap: onTap,
        );
      },
    );
  }
}
