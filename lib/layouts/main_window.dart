import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:teropong/layouts/main_window/explore.dart';

class MainWindow extends StatefulWidget {
  const MainWindow({
    Key? key,
  }) : super(key: key);

  @override
  State createState() => MainWindowState();

  static MainWindowState? of(BuildContext context) {
    return context.findRootAncestorStateOfType<MainWindowState>();
  }
}

extension on NavigationDestination {
  NavigationRailDestination toNavigationRailDestination() =>
      NavigationRailDestination(
        icon: icon,
        label: Text(label),
        selectedIcon: selectedIcon,
      );
}

class MainWindowState extends State
    with TickerProviderStateMixin, WidgetsBindingObserver {
  late TabController exploreTabController;
  int topNavigationCurrentIndex = 0;
  bool topNavigationExtended = false,
      useExtendedSidebar = false,
      useSidebar = false;

  List<NavigationDestination> topNavigationDestinations = [
    NavigationDestination(
      icon: const Icon(FluentIcons.globe_search_24_regular),
      label: "explore",
      selectedIcon: const Icon(FluentIcons.globe_search_24_filled),
    ),
    NavigationDestination(
      icon: const Icon(FluentIcons.timeline_24_regular),
      label: "timeline",
      selectedIcon: const Icon(FluentIcons.timeline_24_filled),
    ),
    NavigationDestination(
      icon: const Icon(FluentIcons.send_copy_24_regular),
      label: "create",
      selectedIcon: const Icon(FluentIcons.send_copy_24_filled),
    ),
    NavigationDestination(
      icon: const Icon(FluentIcons.collections_24_regular),
      label: "collections",
      selectedIcon: const Icon(FluentIcons.collections_24_filled),
    ),
    NavigationDestination(
      icon: const Icon(FluentIcons.person_circle_24_regular),
      label: "profile",
      selectedIcon: const Icon(FluentIcons.person_circle_24_filled),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    return Scaffold(
      body: WindowBorder(
        color: Colors.transparent,
        child: Column(
          children: [
            WindowTitleBarBox(
              child: MoveWindow(
                child: Center(child: Text("teropong")),
              ),
            ),
            Expanded(
              child: Row(
                children: [
                  if (useSidebar)
                    NavigationRail(
                      destinations: topNavigationDestinations
                          .map((el) => el.toNavigationRailDestination())
                          .toList(),
                      extended: useExtendedSidebar,
                      labelType: useExtendedSidebar
                          ? NavigationRailLabelType.none
                          : NavigationRailLabelType.all,
                      onDestinationSelected: (value) {
                        topNavigationCurrentIndex = value;
                        setState(() {});
                      },
                      selectedIndex: topNavigationCurrentIndex,
                    ),
                  Expanded(
                    child: ExplorePage(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: useSidebar
          ? null
          : NavigationBar(
              destinations: topNavigationDestinations,
              onDestinationSelected: (value) {
                topNavigationCurrentIndex = value;
                setState(() {});
              },
              selectedIndex: topNavigationCurrentIndex,
            ),
    );
  }

  @override
  void didChangeDependencies() {
    MediaQueryData mediaQuery = MediaQuery.of(context);
    useSidebar = mediaQuery.size.width >= 600;
    useExtendedSidebar = mediaQuery.size.width >= 840;
    super.didChangeDependencies();
  }

  @override
  void didChangeMetrics() {
    setState(() {});
    super.didChangeMetrics();
  }

  @override
  void initState() {
    super.initState();
    exploreTabController = TabController(length: 3, vsync: this);
    WidgetsBinding.instance.addObserver(this);
  }
}
