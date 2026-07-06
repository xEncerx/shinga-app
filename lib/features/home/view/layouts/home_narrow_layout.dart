import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:shinga/i18n/strings.g.dart';
import 'package:ui_kit/ui_kit.dart';

/// Layout for narrow (mobile) screens.
///
/// Displays a [BottomNavigationBar] for tab switching.
class HomeNarrowLayout extends StatelessWidget {
  /// Creates a [HomeNarrowLayout] widget.
  const HomeNarrowLayout({
    required this.tabsRouter,
    required this.child,
    super.key,
  });

  /// The router used to track and change the active tab.
  final TabsRouter tabsRouter;

  /// The currently active tab content.
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final t = Translations.of(context);

    return Scaffold(
      body: child,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: tabsRouter.activeIndex,
        onTap: (index) {
          if (index == tabsRouter.activeIndex) {
            final stackRouter = tabsRouter.stackRouterOfIndex(index);
            if (stackRouter != null) {
              stackRouter.popUntilRoot();
            }
          } else {
            tabsRouter.setActiveIndex(index);
          }
        },
        items: [
          BottomNavigationBarItem(
            icon: const SaIcon(icon: SaIconSource.huge(HugeIconsStrokeRounded.favouriteCircle)),
            label: t.favorites.sectionName,
          ),
          BottomNavigationBarItem(
            icon: const SaIcon(icon: SaIconSource.huge(HugeIconsStrokeRounded.userCircle)),
            label: t.profile.sectionName,
          ),
          BottomNavigationBarItem(
            icon: const SaIcon(icon: SaIconSource.huge(HugeIconsStrokeRounded.settings02)),
            label: t.settings.sectionName,
          ),
        ],
      ),
    );
  }
}
