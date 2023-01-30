library teropong;

import 'package:teropong/teropong.dart';

/// [InstanceMayHaveFeed]s are [BaseInstance]s which uses a [BaseService] which
/// could get a list of index/feed (e.g. blog posts) from the instance. A
/// A [BaseInstance] implementing this interface does NOT always mean that the
/// given [BaseService] is able to get an index of [BasePost]s or [BaseFeed]s of
/// the [BaseInstance]. Make sure that you have checked the support first by
/// calling [checkForFeedSupport] before calling [getFeeds].
mixin InstanceMayHaveFeed<T extends BaseService> on BaseInstance<T> {
  /// Check whether the [BaseService]'s indexing method is supported on a given
  /// [BaseInstance].
  Future<bool> checkForFeedSupport({
    BaseFeedScope scope = BaseFeedScope.global,
    BaseFeedType type = BaseFeedType.timeline,
  }) async {
    return false;
  }

  /// Check whether the [BaseService]'s indexing method is supported on a given
  /// [BaseInstance].
  Future<BaseFeed<T>?> getFeeds({
    BaseFeedScope scope = BaseFeedScope.global,
    BaseFeedType type = BaseFeedType.timeline,
  }) async {
    return null;
  }
}
