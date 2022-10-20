import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:libadwaita_bitsdojo/libadwaita_bitsdojo.dart';
import 'package:libadwaita/libadwaita.dart';
import 'package:teropong/entities/top_level_menu.dart';
import 'package:teropong/layouts/main_window.dart';

class MainWindowInAdwaita extends StatefulWidget {
  @override
  State createState() => MainWindowStateInAdwaita();
}

class MainWindowStateInAdwaita extends State with WidgetsBindingObserver {
  FlapController flapController = FlapController();
  bool useTabs = false;

  bool isMobile(BuildContext context) =>
      MediaQuery.of(context).size.width < 600;
  bool isSuperMobile(BuildContext context) =>
      MediaQuery.of(context).size.width < 00;

  @override
  Widget build(BuildContext context) {
    MainWindowState commonState = MainWindow.of(context)!;
    bool isMobile = this.isMobile(context);
    bool isSuperMobile = this.isSuperMobile(context);
    List<AdwSidebarItem> sidebarItems = [];
    List<ViewSwitcherData> tabs = [];

    for (var el in commonState.mainNavigation) {
      sidebarItems.add(AdwSidebarItem(
          labelWidget: Row(
        children: [
          Icon(el.materialIcon, size: 16),
          const SizedBox(width: 8),
          Text(el.getName()),
        ],
      )));
      tabs.add(ViewSwitcherData(icon: el.materialIcon, title: el.getName()));
    }

    return AdwScaffold(
      actions: AdwActions().bitsdojo,
      body: AdwViewStack(
        children: [
          AdwClamp.scrollable(
            child: AdwPreferencesGroup(
              children: [
                AdwSwitchRow(
                  title: 'Locked',
                  subtitle: """
Sidebar visibility doesn't change when fold state changes""",
                  value: false,
                  onChanged: (val) {
                    // locked = val;
                    setState(() {});
                  },
                )
              ],
            ),
          ),
        ],
      ),
      end: [
        AdwHeaderButton(
          icon: const Icon(Icons.notifications),
          onPressed: () {},
        )
      ],
      flap: !isMobile
          ? (bool isOpened) {
              return AdwSidebar(
                currentIndex: commonState.mainNavigationCurrentIndex,
                isDrawer: false,
                onSelected: (int index) {
                  commonState.mainNavigationCurrentIndex = index;
                  setState(() {});
                },
                children: sidebarItems,
              );
            }
          : null,
      start: [
        AdwHeaderButton(
          icon: const Icon(Icons.search),
          onPressed: () {},
        )
      ],
      title: const Text("Teropong"),
      viewSwitcher: isMobile
          ? AdwViewSwitcher(
              currentIndex: commonState.mainNavigationCurrentIndex,
              onViewChanged: (int index) {
                commonState.mainNavigationCurrentIndex = index;
                setState(() {});
              },
              tabs: tabs,
            )
          : null,
    );
  }

  @override
  void didChangeMetrics() {
    super.didChangeMetrics();
    setState(() {});
  }
}
