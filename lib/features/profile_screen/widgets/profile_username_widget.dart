import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/core.dart';
import '../../../domain/domain.dart';
import '../../../i18n/strings.g.dart';
import '../../features.dart';

class ProfileUsernameWidget extends StatelessWidget {
  const ProfileUsernameWidget({
    super.key,
    required this.username,
  });

  final String username;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      spacing: 5,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          username,
          style: Theme.of(context).textTheme.titleLarge.semiBold,
        ),
        IconButton(
          onPressed: () => _showEditUsernameDialog(context),
          style: IconButton.styleFrom(
            padding: EdgeInsets.zero,
            minimumSize: const Size(28, 28),
          ),
          icon: Icon(
            Icons.edit_outlined,
            color: theme.colorScheme.primary,
            size: 20,
          ),
        ),
      ],
    );
  }

  Future<void> _showEditUsernameDialog(BuildContext context) async {
    final result = await showTextInputDialog(
      context: context,
      title: t.profile.editUsername.title,
      autoSubmit: true,
      isDestructiveAction: true,
      fullyCapitalizedForMaterial: false,
      textFields: [
        DialogTextField(
          hintText: t.profile.editUsername.hint,
          validator: TextFieldFilterService.username(
            minLengthErrorText: '>= 3',
            maxLengthErrorText: '<= 20',
            invalidCharacterErrorText: 'a-z, A-Z, 0-9, _, -',
          ),
          initialText: username,
        ),
      ],
    );
    if (result != null && result.isNotEmpty && context.mounted) {
      final newUsername = result.first.trim();
      if (newUsername.isNotEmpty && newUsername != username) {
        context.read<ProfileBloc>().add(UpdateUsername(newUsername));
      }
    }
  }
}
