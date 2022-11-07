import 'dart:math';

import 'package:flutter/material.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:teropong/entities/account.dart';
import 'package:teropong/entities/activitypub.dart';
import 'package:teropong/entities/instance.dart';
import 'package:teropong/entities/post.dart';
import 'package:teropong/entities/service/mastodon.dart';
import 'package:teropong/entities/service/misskey.dart';
import 'package:teropong/entities/user.dart';
import 'package:teropong/layouts/deck/list.dart';
import 'package:teropong/layouts/main_window.dart';

class ExplorePage extends StatefulWidget {
  const ExplorePage({super.key});

  @override
  State createState() => ExploreState();
}

class ExploreState extends State {
  List<Instance>? instances;
  Map<String, String> minPostIdData = {}, maxPostIdData = {};
  List<Post> recommendedPosts = [];
  ScrollController scrollController = ScrollController();
  bool _isNotAtTop = false;
  final PagingController<int, Post> _feedPagingController =
      PagingController(firstPageKey: 1);

  int _asciiSum(String string) {
    int i, sum = 0;
    for (i = 0; i < string.length; i++) {
      sum += string.codeUnitAt(i);
    }
    return sum;
  }

  Future<void> _fetchPosts(int pageKey) async {
    instances ??= [
      (await Instance.of(Uri.parse("https://botsin.space"),
          service: MastodonService())),
      (await Instance.of(Uri.parse("https://misskey.id"),
          service: MisskeyService())),
      (await Instance.of(Uri.parse("https://bots.reinhart1010.id"),
          service: MisskeyService())),
      (await Instance.of(Uri.parse("https://misskey.io"),
          service: MisskeyService())),
      (await Instance.of(Uri.parse("https://mastodon.social"),
          service: MastodonService())),
      (await Instance.of(Uri.parse("https://mstdn.social"),
          service: MastodonService())),
      // (await Instance.of(Uri.parse("https://c.im"),
      //     service: MastodonService())),
    ].where((el) => el != null).map((el) => el as Instance).toList();
    Random random = Random();
    List<Post> posts = [];
    int failureCount = 0;
    do {
      Instance selected = instances![random.nextInt(instances!.length)];
      posts = await selected.service!.getTimelinePosts(Account(selected),
          untilId: minPostIdData[selected.instanceUrl.host]);
      failureCount++;
    } while (posts.isEmpty && failureCount < 5);
    for (Post post in posts) {
      String server = post.internalIds.entries.elementAt(0).key;
      String internalId = post.internalIds.entries.elementAt(0).value;
      if (!minPostIdData.containsKey(server) ||
          _asciiSum(minPostIdData[server]!) > _asciiSum(internalId)) {
        minPostIdData[post.uri.host] = internalId;
      }
      if (!maxPostIdData.containsKey(server) ||
          _asciiSum(maxPostIdData[server]!) < _asciiSum(internalId)) {
        maxPostIdData[post.uri.host] = internalId;
      }
    }
    _feedPagingController.appendPage(posts, pageKey + 1);
  }

  @override
  Widget build(BuildContext context) {
    MainWindowState mainWindow = MainWindow.of(context)!;
    ThemeData theme = Theme.of(context);

    return ListDeck(
      // featured: Post(
      //   type: ActivityType.note,
      //   uri: Uri.parse("https://google.com"),
      //   user: User(host: "asasas", username: "asasas"),
      //   content: "asasas",
      // ),
      pagingController: _feedPagingController,
      scrollController: scrollController,
    );
  }

  @override
  void initState() {
    _feedPagingController.addPageRequestListener((pageKey) {
      _fetchPosts(pageKey);
    });
    super.initState();
  }
}
