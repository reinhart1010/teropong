import 'package:flutter/widgets.dart';
import 'package:libadwaita_core/libadwaita_core.dart';
import 'package:libadwaita/libadwaita.dart';
import 'package:teropong/layouts/main_window.dart';

class MainWindowInAdwaita extends StatefulWidget {
  @override
  State createState() => MainWindowStateInAdwaita();
}

class MainWindowStateInAdwaita extends MainWindowState {
  bool useTabs = false;

  @override
  Widget build(BuildContext context) {
    return AdwScaffold(
      actions: AdwActions(),
        body: GtkStackSidebar(
          content: Text("Ugh Schaloob!"),
          sidebar: Text("Sidebar"),
          onContentPopupClosed: () {},
        ),
        );
  }
}
