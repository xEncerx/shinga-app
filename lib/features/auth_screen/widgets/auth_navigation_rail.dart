import 'package:flutter/material.dart';
import 'package:sidebarx/sidebarx.dart';

import '../../../core/core.dart';

class AuthNavigationRail extends StatefulWidget {
  const AuthNavigationRail({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  final int currentIndex;
  final void Function(int) onTap;

  @override
  State<AuthNavigationRail> createState() => _AuthNavigationRailState();
}

class _AuthNavigationRailState extends State<AuthNavigationRail> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SidebarX(
      showToggleButton: false,
      controller: SidebarXController(selectedIndex: widget.currentIndex),
      footerBuilder: (context, extended) => const Padding(
        padding: EdgeInsets.symmetric(
          horizontal: 3,
          vertical: 20,
        ),
        child: AppVersionBadge(),
      ),
      theme: SidebarXTheme(
        width: 60,
        decoration: BoxDecoration(
          color: theme.colorScheme.secondary,
        ),
        itemTextPadding: const EdgeInsets.symmetric(vertical: 8),
        selectedItemTextPadding: const EdgeInsets.symmetric(vertical: 8),
        itemDecoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
        ),
        selectedIconTheme: IconThemeData(color: theme.colorScheme.onPrimary),
        selectedItemDecoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              theme.colorScheme.primary,
              theme.primaryColorDark.withValues(alpha: 0.5),
            ],
          ),
        ),
      ),
      items: [
        SidebarXItem(
          icon: Icons.arrow_forward_rounded,
          label: 'SignIn',
          onTap: () => widget.onTap(0),
        ),
        SidebarXItem(
          icon: Icons.add_rounded,
          label: 'SignUp',
          onTap: () => widget.onTap(1),
        ),
        SidebarXItem(
          icon: Icons.lock_reset_rounded,
          label: 'Reset Password',
          onTap: () => widget.onTap(2),
        ),
      ],
    );
  }
}
