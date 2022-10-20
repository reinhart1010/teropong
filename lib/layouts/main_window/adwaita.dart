import 'package:flutter/widgets.dart';
import 'package:libadwaita_core/libadwaita_core.dart';
import 'package:libadwaita/libadwaita.dart';
import 'package:teropong/layouts/main_window.dart';

class MainWindowInAdwaita extends StatefulWidget {
  @override
  State createState() => MainWindowStateInAdwaita();
}

class MainWindowStateInAdwaita extends MainWindowState {
  FlapController flapController = FlapController();
  bool useTabs = false;

  @override
  Widget build(BuildContext context) {
    return AdwScaffold(
      actions: AdwActions(),
      body: AdwButton.circular(
        child: Text("Ugh Schaloob"),
        onPressed: () {
          flapController.toggle();
        },
      ),
      flapController: flapController,
      flap: (bool isOpened) => AdwSidebar.builder(
        currentIndex: 0,
        itemCount: 1,
        itemBuilder: (BuildContext context, int index, bool isSelected) {
          return AdwSidebarItem(label: "Sidebar item");
        },
        onSelected: (int index) {},
      ),
      title: Text("Teropong"),
    );
  }
}
