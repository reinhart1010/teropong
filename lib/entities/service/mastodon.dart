import 'package:dio/dio.dart';
import 'package:teropong/entities/account.dart';
import 'package:teropong/entities/post.dart';
import 'package:teropong/utils/parse_utils.dart';
import 'package:teropong/utils/parse_utils/mastodon.dart';

import '../activitypub.dart';
import '../instance.dart';
import '../service.dart';

class MastodonService implements Service {
  @override
  Set<ActivityType> commonPostTypes = {ActivityType.note};
  @override
  Instance? currentInstance;
  @override
  String description = "",
      name = "Mastodon",
      projectUrl = "https://joinmastodon.org";
  @override
  List<String> instanceListRecommendationUrl = [
    "https://joinmastodon.org/servers"
  ];
  @override
  late ParseUtils parseUtils;

  MastodonService() {
    parseUtils = MastodonParseUtils(this);
  }

  @override
  Future<Instance?> getInstance(Uri instanceUrl) async {
    Dio dio = Dio();
    try {
      Response res =
          await dio.get(instanceUrl.resolve("/api/v1/instance").toString());
      Map<String, dynamic> serverInfo = res.data as Map<String, dynamic>;
      Instance instance = Instance(
        instanceUrl,
        this,
        registrationPolicy:
            await parseUtils.parseInstanceRegistrationPolicy(serverInfo),
        stats: await parseUtils.parseInstanceStats(serverInfo["stats"]),
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
    String scope = account.credentialType == AccountCredentialType.anonymous
        ? "public"
        : "home";
    Dio dio = Dio();
    String requestPath =
        "/api/v1/timelines/$scope?local=${withLocal && !withRemote}&remote=${!withLocal && withRemote}";
    if (sinceId != null && sinceId.isNotEmpty) {
      requestPath += "&min_id=${Uri.encodeFull(sinceId)}";
    }
    if (untilId != null && untilId.isNotEmpty) {
      requestPath += "&max_id=${Uri.encodeFull(untilId)}";
    }
    if (onlyMedia) {
      requestPath += "&only_media=$onlyMedia";
    }
    Response res = await dio
        .get(account.instance.instanceUrl.resolve(requestPath).toString());
    List<Map<String, dynamic>> originalPosts = (res.data as List<dynamic>)
        .map((el) => el as Map<String, dynamic>)
        .toList();
    List<Post> posts = [];
    for (var el in originalPosts) {
      Post? parsed = await parseUtils.parsePost(el);
      if (parsed != null) {
        posts.add(parsed);
      }
    }
    return posts;
  }
}
