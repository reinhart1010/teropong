import 'package:dio/dio.dart';
import 'package:teropong/entities/account.dart';
import 'package:teropong/entities/post.dart';

import '../activitypub.dart';
import '../instance.dart';
import '../service.dart';

class MastodonService implements Service {
  @override
  Set<ActivityType> commonPostTypes = {ActivityType.note};
  @override
  String description = "",
      name = "Mastodon",
      projectUrl = "https://joinmastodon.org";
  @override
  List<String> instanceListRecommendationUrl = [
    "https://joinmastodon.org/servers"
  ];

  @override
  Future<Instance?> getInstance(Uri instanceUrl) async {
    Dio dio = Dio();
    try {
      Response res =
          await dio.get(instanceUrl.resolve("/api/v1/instance").toString());
      Map<String, dynamic> serverInfo = res.data as Map<String, dynamic>;
      return Instance(
        instanceUrl,
        this,
        registrationPolicy: InstanceRegistrationPolicy.fromMastodon(serverInfo),
        stats: InstanceStats.fromMastodon(serverInfo["stats"]),
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
    String scope = account.credentialType == AccountCredentialType.anonymous
        ? "public"
        : "home";
    Dio dio = Dio();
    Response res = await dio.get(account.instance.instanceUrl
        .resolve(
            "/api/v1/timelines/$scope?local=${withLocal && !withRemote}&remote=${!withLocal && withRemote}")
        .toString());
    List<Map<String, dynamic>> originalPosts = res.data;
    List<Post> posts = [];
    for (var el in originalPosts) {
      Post? parsed = Post.fromMastodon(el);
      if (parsed != null) {
        posts.add(parsed);
      }
    }
    return posts;
  }
}
