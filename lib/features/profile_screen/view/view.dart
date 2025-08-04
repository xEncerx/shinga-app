import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';

export 'crop_avatar_screen.dart';
export 'profile_screen.dart';

@RoutePage()
class AutoProfileScreen extends StatelessWidget {
  const AutoProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const AutoRouter();
  }
}
