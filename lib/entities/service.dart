import 'package:teropong/entities/account.dart';
import 'package:teropong/entities/post.dart';
import 'package:teropong/utils/parse_utils.dart';

import 'activitypub.dart';
import 'instance.dart';

abstract class Service {
  Set<ActivityType> get commonPostTypes;
  Instance? get currentInstance;
  String get description;
  List<String> get instanceListRecommendationUrl;
  String get name;
  String get projectUrl;
  ParseUtils get parseUtils;

  Future<List<Post>> getTimelinePosts(
    Account account, {
    String? sinceId,
    String? untilId,
    bool onlyMedia = false,
    bool withLocal = true,
    bool withRemote = true,
  }) {
    throw UnimplementedError();
  }

  Future<Instance?> getInstance(Uri instanceUrl) {
    throw UnimplementedError();
  }
}

enum ServiceCapability {
  chat,
  post,
  mediaGallery,
}
