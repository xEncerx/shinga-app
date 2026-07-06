import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'package:shinga/i18n/strings.g.dart';
import 'package:ui_kit/ui_kit.dart';

/// Layout for wide (tablet and desktop) screens.
///
/// Displays a [SaSideBar] for tab switching. The sidebar expands
/// when the breakpoint is larger than [TABLET].
class HomeWideLayout extends StatelessWidget {
  /// Creates a [HomeWideLayout] widget.
  const HomeWideLayout({
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
    final isWide = ResponsiveBreakpoints.of(context).largerThan(TABLET);

    return Scaffold(
      body: Row(
        children: [
          SaSideBar(
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
              SaSidebarItem(
                icon: const SaIconSource.huge(HugeIconsStrokeRounded.favouriteCircle),
                label: t.favorites.sectionName,
              ),
              SaSidebarItem(
                icon: const SaIconSource.huge(HugeIconsStrokeRounded.userCircle),
                label: t.profile.sectionName,
              ),
              SaSidebarItem(
                icon: const SaIconSource.huge(HugeIconsStrokeRounded.settings02),
                label: t.settings.sectionName,
              ),
            ],
            extended: isWide,
          ),
          Expanded(child: child),
        ],
      ),
    );
  }
}
