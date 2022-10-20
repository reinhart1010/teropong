import 'package:teropong/entities/account.dart';
import 'package:teropong/entities/post.dart';

import 'activitypub.dart';
import 'instance.dart';

abstract class Service {
  Set<ActivityType> get commonPostTypes;
  String get description;
  List<String> get instanceListRecommendationUrl;
  String get name;
  String get projectUrl;

  Future<List<Post>> getTimelinePosts(
    Account account, {
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
