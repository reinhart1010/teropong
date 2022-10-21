import 'package:dio/dio.dart';
import 'package:teropong/entities/post.dart';
import 'package:teropong/entities/account.dart';

import '../activitypub.dart';
import '../instance.dart';
import '../service.dart';

class MisskeyService implements Service {
  @override
  Set<ActivityType> commonPostTypes = {ActivityType.note};
  @override
  String description = "🌎 An interplanetary microblogging platform 🚀",
      name = "Misskey",
      projectUrl = "https://misskey-hub.net";
  @override
  List<String> instanceListRecommendationUrl = [
    "https://misskey-hub.net/en/instances.html"
  ];

  @override
  Future<Instance?> getInstance(Uri instanceUrl) async {
    Dio dio = Dio();
    try {
      Response res =
          await dio.post(instanceUrl.resolve("/api/meta").toString());
      Map<String, dynamic> serverInfo = res.data as Map<String, dynamic>;
      return Instance(
        instanceUrl,
        this,
        registrationPolicy: InstanceRegistrationPolicy.fromMisskey(serverInfo),
        stats: await InstanceStats.fromMisskey(instanceUrl),
        title: serverInfo["title"],
      );
    } on DioError catch (_) {
      return null;
    }
  }

  @override
  Future<List<Post>> getTimelinePosts(
    Account account, {
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
    Response res = await dio.post(account.instance.instanceUrl
        .resolve("/api/notes/$scope-timeline")
        .toString());
    List<Map<String, dynamic>> originalPosts = (res.data as List<dynamic>)
        .map((el) => el as Map<String, dynamic>)
        .toList();
    List<Post> posts = [];
    for (var el in originalPosts) {
      Post? parsed = Post.fromMisskey(el);
      if (parsed != null) {
        posts.add(parsed);
      }
    }
    return posts;
  }
}
