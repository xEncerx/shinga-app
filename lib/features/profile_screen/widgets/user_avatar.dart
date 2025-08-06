import 'package:flutter/material.dart';
import 'package:octo_image/octo_image.dart';

import '../../../core/core.dart';
import '../../features.dart';

class UserAvatar extends StatelessWidget {
  const UserAvatar({super.key, required this.avatarUrl});

  final String avatarUrl;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPress: () => showDialog<void>(
        context: context,
        builder: (_) => const ChooseImageAlertDialog(),
      ),
      child: SizedBox(
        width: 100,
        height: 100,
        child: ClipOval(
          child: OctoImage(
            image: NetworkImage(avatarUrl),
            fit: BoxFit.cover,
            errorBuilder: (_, _, error) => _buildErrorWidget(),
          ),
        ),
      ),
    ).clickable;
  }

  /// Builds a fallback widget when an error occurs loading the image.
  Widget _buildErrorWidget() {
    return Image.asset(
      "assets/images/404_placeholder.png",
      fit: BoxFit.cover,
    );
  }
}
