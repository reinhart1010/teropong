import 'package:adwaita/adwaita.dart' as adwaita;
import 'package:enum_to_string/enum_to_string.dart';
import 'package:fluent_ui/fluent_ui.dart' as fluent;
import 'package:flutter/cupertino.dart' as ios;
import 'package:flutter/material.dart' as material;
import 'package:flutter/widgets.dart';
import 'package:macos_ui/macos_ui.dart' as macos;
import 'package:teropong/entities/ui_theme.dart';
import 'package:teropong/layouts/main_window.dart';

void main(List<String> args) {
  UITheme uiTheme = UITheme.adwaita;
  if (args.isNotEmpty && UITheme.values.map((e) => e.toString()).contains(args[0].toLowerCase())) {
    uiTheme = EnumToString.fromString(UITheme.values, args[0].toLowerCase())!;
  }
  runApp(BaseApp(
    home: MainWindow(),
    uiTheme: uiTheme,
  ));
}

class BaseApp extends StatefulWidget {
  final Widget? home;
  final String? initialRoute;
  final UITheme uiTheme;

  const BaseApp({
    this.home,
    this.initialRoute,
    this.uiTheme = UITheme.material,
    Key? key,
  }) : super(key: key);

  @override
  State createState() => BaseAppState();

  static BaseAppState? of(BuildContext context) {
    return context.findRootAncestorStateOfType<BaseAppState>();
  }
}

class BaseAppState extends State {
  final ValueNotifier<material.ThemeMode> themeNotifier =
      ValueNotifier(material.ThemeMode.system);

  @override
  Widget build(BuildContext context) {
    BaseApp app = widget as BaseApp;
    return ValueListenableBuilder<material.ThemeMode>(
      valueListenable: themeNotifier,
      builder: (_, material.ThemeMode currentMode, __) {
        switch (app.uiTheme) {
          case UITheme.adwaita:
            return material.MaterialApp(
              theme: adwaita.AdwaitaThemeData.light(),
              darkTheme: adwaita.AdwaitaThemeData.dark(),
              debugShowCheckedModeBanner: false,
              initialRoute: app.initialRoute,
              home: app.home,
              themeMode: currentMode,
            );
          case UITheme.fluent:
            return fluent.FluentApp(
              debugShowCheckedModeBanner: false,
              initialRoute: app.initialRoute,
              home: app.home,
              themeMode: currentMode,
            );
          case UITheme.ios:
            return ios.CupertinoApp(
              debugShowCheckedModeBanner: false,
              initialRoute: app.initialRoute,
              home: app.home,
              theme: ios.CupertinoThemeData(
                brightness: currentMode == material.ThemeMode.system
                    ? null
                    : (currentMode == material.ThemeMode.light
                        ? ios.Brightness.light
                        : ios.Brightness.dark),
              ),
            );
          case UITheme.macos:
            return macos.MacosApp(
              debugShowCheckedModeBanner: false,
              initialRoute: app.initialRoute,
              home: app.home,
              themeMode: currentMode,
            );
          default:
            return material.MaterialApp(
              theme: material.ThemeData.light(useMaterial3: true),
              darkTheme: material.ThemeData.dark(useMaterial3: true),
              debugShowCheckedModeBanner: false,
              initialRoute: app.initialRoute,
              home: app.home,
              themeMode: currentMode,
            );
        }
      },
    );
  }
}
