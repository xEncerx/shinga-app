import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class UserAvatar extends StatelessWidget {
  const UserAvatar({super.key, required this.avatarUrl});

  final String avatarUrl;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 100,
      height: 100,
      child: ClipOval(
        child: CachedNetworkImage(
          fit: BoxFit.cover,
          imageUrl: avatarUrl,
          errorWidget: (_, _, error) => _buildErrorWidget(),
        ),
      ),
    );
  }

  /// Builds a fallback widget when an error occurs loading the image.
  Widget _buildErrorWidget() {
    return Image.asset(
      "assets/images/404_placeholder.png",
      fit: BoxFit.cover,
    );
  }
}
