import 'dart:io' show Platform;

import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:teropong/entities/post.dart';
import 'package:teropong/layouts/main_window.dart';

void main(List<String> args) {
  bool isDesktop = !kIsWeb && !Platform.isAndroid && !Platform.isIOS;
  runApp(BaseApp(isDesktop: isDesktop));
  if (isDesktop) {
    doWhenWindowReady(() {
      appWindow.minSize = const Size(400, 400);
      appWindow.alignment = Alignment.center;
      appWindow.show();
    });
  }
}

class BaseApp extends StatefulWidget {
  final bool isDesktop;
  const BaseApp({
    required this.isDesktop,
    Key? key,
  }) : super(key: key);

  @override
  State createState() => BaseAppState();

  static BaseAppState? of(BuildContext context) {
    return context.findRootAncestorStateOfType<BaseAppState>();
  }
}

class BaseAppState extends State<BaseApp> {
  final ValueNotifier<ThemeMode> themeNotifier =
      ValueNotifier(ThemeMode.system);

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeNotifier,
      builder: (_, ThemeMode currentMode, __) {
        return MaterialApp(
          theme: FlexColorScheme.light(
            scheme: FlexScheme.indigo,
            useMaterial3: true,
          ).toTheme,
          darkTheme: FlexColorScheme.dark(
            scheme: FlexScheme.indigo,
            useMaterial3: true,
          ).toTheme,
          debugShowCheckedModeBanner: false,
          initialRoute: "/home",
          routes: {
            "/home": (context) => MainWindow(isDesktop: widget.isDesktop),
            "/post": (context) => MainWindow(isDesktop: widget.isDesktop),
          },
          themeMode: currentMode,
        );
      },
    );
  }
}

class CommonPageArguments {
  Post? post;
  CommonPageArguments({this.post});
}
