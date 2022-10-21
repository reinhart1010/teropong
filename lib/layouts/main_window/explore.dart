import 'package:basic_utils/basic_utils.dart';
import 'package:flutter/material.dart';
import 'package:teropong/entities/account.dart';
import 'package:teropong/entities/instance.dart';
import 'package:teropong/entities/post.dart';
import 'package:teropong/entities/service/mastodon.dart';
import 'package:teropong/layouts/main_window.dart';

class ExplorePage extends StatefulWidget {
  const ExplorePage({super.key});

  @override
  State createState() => ExploreState();
}

class ExploreState extends State {
  List<Post> recommendedPosts = [];

  Future<void> _fetchPosts() async {
    Instance? instance = await Instance.of(Uri.parse("https://botsin.space"),
        service: MastodonService());
    recommendedPosts =
        await MastodonService().getTimelinePosts(Account(instance!));
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    MainWindowState mainWindow = MainWindow.of(context)!;
    ThemeData theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        title: Text("🔭 go explore the fediverse!"),
      ),
      body: SingleChildScrollView(
          padding: EdgeInsetsDirectional.fromSTEB(
              mainWindow.useSidebar ? 0 : 12, 12, 12, 12),
          child: Center(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 768),
              child: Column(
                children:
                    recommendedPosts.map((el) => el.getCard(context)).toList(),
              ),
            ),
          )),
    );
  }

  @override
  void initState() {
    _fetchPosts();
    super.initState();
  }
}
