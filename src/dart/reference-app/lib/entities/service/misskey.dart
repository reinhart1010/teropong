import 'package:dio/dio.dart';
import 'package:teropong/entities/post.dart';
import 'package:teropong/entities/account.dart';
import 'package:teropong/utils/parse_utils.dart';
import 'package:teropong/utils/parse_utils/misskey.dart';

import '../activitypub.dart';
import '../instance.dart';
import '../service.dart';

class MisskeyService implements Service {
  @override
  Set<ActivityType> commonPostTypes = {ActivityType.note};
  @override
  Instance? currentInstance;
  @override
  String description = "🌎 An interplanetary microblogging platform 🚀",
      name = "Misskey",
      projectUrl = "https://misskey-hub.net";
  @override
  List<String> instanceListRecommendationUrl = [
    "https://misskey-hub.net/en/instances.html"
  ];
  @override
  late ParseUtils parseUtils;

  MisskeyService() {
    parseUtils = MisskeyParseUtils(this);
  }

  @override
  Future<Instance?> getInstance(Uri instanceUrl) async {
    Dio dio = Dio();
    try {
      Response res =
              await dio.post(instanceUrl.resolve("/api/meta").toString()),
          statsRes =
              await dio.post(instanceUrl.resolve("/api/stats").toString());
      Map<String, dynamic> serverInfo = res.data as Map<String, dynamic>,
          serverStatsInfo = statsRes.data as Map<String, dynamic>;

      Instance instance = Instance(
        instanceUrl,
        this,
        registrationPolicy:
            await parseUtils.parseInstanceRegistrationPolicy(serverInfo),
        stats: await parseUtils.parseInstanceStats(serverStatsInfo),
        title: serverInfo["title"],
      );
      currentInstance = instance;
      return instance;
    } on DioError catch (_) {
      return null;
    }
  }

  @override
  Future<List<Post>> getTimelinePosts(
    Account account, {
    String? sinceId,
    String? untilId,
    bool onlyMedia = false,
    bool withLocal = true,
    bool withRemote = true,
  }) async {
    String scope = "";
    if (account.credentialType == AccountCredentialType.anonymous) {
      scope = "global";
    } else {
      if (withLocal == true && withRemote == true) {
        scope = "hybrid";
      } else if (withLocal = true) {
        scope = "local";
      } else {
        scope = "global";
      }
    }
    Dio dio = Dio();
    Map<String, String> jsonData = {};
    if (sinceId != null && sinceId.isNotEmpty) {
      jsonData["sinceId"] = sinceId;
    }
    if (untilId != null && untilId.isNotEmpty) {
      jsonData["untilId"] = untilId;
    }
    if (onlyMedia) {
      jsonData["withMedia"] = "true";
    }
    Response res = await dio.post(
        account.instance.instanceUrl
            .resolve("/api/notes/$scope-timeline")
            .toString(),
        data: jsonData);
    List<Map<String, dynamic>> originalPosts = (res.data as List<dynamic>)
        .map((el) => el as Map<String, dynamic>)
        .toList();
    List<Post> posts = [];
    for (var el in originalPosts) {
      Post? parsed = await parseUtils.parsePost(el, account);
      if (parsed != null) {
        posts.add(parsed);
      }
    }
    return posts;
  }

  @override
  Future<void> react(Account account, String postId,
      {String emoji = "❤️"}) async {
    Dio dio = Dio();
    await dio.post(
      account.instance.instanceUrl
          .resolve("/api/notes/reactions/create")
          .toString(),
      data: {"noteId": postId, "reaction": emoji},
    );
  }
}
