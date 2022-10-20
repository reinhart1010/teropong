import 'package:flutter/material.dart' as material;
import 'package:flutter/widgets.dart';
import 'package:teropong/entities/top_level_menu.dart';
import 'package:teropong/entities/ui_theme.dart';
import 'package:teropong/layouts/main_window/adwaita.dart';
import 'package:teropong/main.dart';

class MainWindow extends StatefulWidget {
  MainWindow({
    Key? key,
  }) : super(key: key);

  @override
  State createState() => MainWindowState();

  static MainWindowState? of(BuildContext context) {
    return context.findRootAncestorStateOfType<MainWindowState>();
  }
}

class MainWindowState extends State {
  final List<TopLevelMenu> mainNavigation = [
    TopLevelMenu(TopLevelMenuDestination.explore,
        materialIcon: material.Icons.public_outlined),
    TopLevelMenu(TopLevelMenuDestination.timeline,
        materialIcon: material.Icons.history_outlined),
    TopLevelMenu(TopLevelMenuDestination.create,
        materialIcon: material.Icons.add_circle_outline),
    TopLevelMenu(TopLevelMenuDestination.collections,
        materialIcon: material.Icons.feed_outlined),
    TopLevelMenu(TopLevelMenuDestination.profile,
        materialIcon: material.Icons.person_outline),
  ];
  int mainNavigationCurrentIndex = 0;

  @override
  Widget build(BuildContext context) {
    BaseAppState baseAppState = BaseApp.of(context)!;
    return MainWindowInAdwaita();
  }
}
