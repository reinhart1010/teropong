import 'package:enum_to_string/enum_to_string.dart';
import 'package:teropong/entities/user.dart';

import 'activitypub.dart';

class Post {
  PostAppSource? appSource;
  //TODO: Add Attachments
  String? content;
  DateTime? createdAt, updatedAt;
  bool isSensitive;
  BigInt? reactionCount, replyCount, repostCount;
  Map<String, BigInt>? reactionTypes;
  Post? replyOf, repostOf;
  ActivityType type;
  Uri uri;
  User user;
  PostVisibility visibility;

  Post({
    this.appSource,
    this.content,
    this.createdAt,
    this.isSensitive = false,
    this.reactionCount,
    this.reactionTypes,
    this.replyCount,
    this.replyOf,
    this.repostCount,
    this.repostOf,
    required this.type,
    this.updatedAt,
    required this.uri,
    required this.user,
    this.visibility = PostVisibility.public,
  });

  BigInt importMultipleReactions(Map<String, dynamic> data) {
    reactionCount = BigInt.zero;
    reactionTypes = {};
    for (var el in data.entries) {
      BigInt count = BigInt.parse(el.value);
      reactionTypes![el.key] = count;
      reactionCount = reactionCount! + count;
    }
    return reactionCount!;
  }

  static Post? fromMastodon(dynamic data) {
    try {
      Map<String, dynamic> postInfo = data as Map<String, dynamic>;
      Uri uri = Uri.parse(postInfo["uri"]);
      User user = User.fromMastodon(postInfo["account"])!;
      Post res = Post(type: ActivityType.note, uri: uri, user: user);
      if (postInfo.containsKey("visibility") &&
          EnumToString.fromString(
                  PostVisibility.values, postInfo["visibility"]) !=
              null) {
        res.visibility = EnumToString.fromString(
            PostVisibility.values, postInfo["visibility"])!;
      }
      if (postInfo.containsKey("replies_count")) {
        res.replyCount = BigInt.tryParse(postInfo["replies_count"]);
      }
      if (postInfo.containsKey("reblogs_count")) {
        res.repostCount = BigInt.tryParse(postInfo["reblogs_count"]);
      }
      if (postInfo.containsKey("favourites_count")) {
        res.reactionCount = BigInt.tryParse(postInfo["favourites_count"]);
      }
      if (postInfo.containsKey("content")) {
        res.content = postInfo["content"];
      }
      if (postInfo.containsKey("reblog")) {
        res.repostOf = Post.fromMastodon(postInfo["reblog"]);
      }
      return res;
    } catch (e) {
      return null;
    }
  }

  static Post? fromMisskey(dynamic data) {
    try {
      Map<String, dynamic> postInfo = data as Map<String, dynamic>;
      Uri uri = Uri.parse(postInfo["uri"]);
      User user = User.fromMisskey(postInfo["account"])!;
      Post res = Post(type: ActivityType.note, uri: uri, user: user);
      if (postInfo.containsKey("visibility")) {
        switch (postInfo["visibility"]) {
          case "followers":
            res.visibility = PostVisibility.private;
            break;
          case "private":
            res.visibility = PostVisibility.direct;
            break;
        }
      }
      if (postInfo.containsKey("repliesCount")) {
        res.replyCount = BigInt.tryParse(postInfo["repliesCount"]);
      }
      if (postInfo.containsKey("renoteCount")) {
        res.repostCount = BigInt.tryParse(postInfo["renoteCount"]);
      }
      if (postInfo.containsKey("reactions")) {
        res.importMultipleReactions(postInfo["reactions"] as Map<String, int>);
      }
      if (postInfo.containsKey("content")) {
        res.content = postInfo["content"];
      }
      if (postInfo.containsKey("reply")) {
        res.replyOf = Post.fromMisskey(postInfo["reply"]);
      }
      if (postInfo.containsKey("renote")) {
        res.repostOf = Post.fromMisskey(postInfo["renote"]);
      }
      return res;
    } catch (e) {
      return null;
    }
  }
}

class PostAppSource {
  String name;
  Uri url;
  PostAppSource(this.name, this.url);
}

enum PostVisibility {
  public,
  unlisted,
  private,
  direct,
}
