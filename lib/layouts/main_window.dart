import 'package:flutter/widgets.dart';
import 'package:teropong/entities/ui_theme.dart';
import 'package:teropong/layouts/main_window/adwaita.dart';
import 'package:teropong/main.dart';

class MainWindow extends StatelessWidget {
  MainWindow({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    BaseAppState state = BaseApp.of(context)!;
    return MainWindowInAdwaita();
  }
}

abstract class MainWindowState extends State {}
