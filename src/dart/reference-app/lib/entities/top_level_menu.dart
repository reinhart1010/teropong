import "package:flutter/material.dart";
import "package:flutter_translate/flutter_translate.dart";

class TopLevelMenu {
  final TopLevelMenuDestination destination;
  late String id;
  final IconData materialIcon;
  final bool showInSideBar, showInTabBar;

  TopLevelMenu(this.destination,
      {String? id,
      required this.materialIcon,
      this.showInSideBar = true,
      this.showInTabBar = true}) {
    this.id = id ?? destination.name;
  }

  String getName() => id;
  // String getName() => translate("topLevelMenu.$id");
}

enum TopLevelMenuDestination {
  collections,
  create,
  explore,
  more,
  profile,
  search,
  timeline,
}
