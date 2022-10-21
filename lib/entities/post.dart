import 'package:enum_to_string/enum_to_string.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:read_more_less/read_more_less.dart';
import 'package:teropong/entities/user.dart';

import 'activitypub.dart';

class Post {
  PostAppSource? appSource;
  //TODO: Add Attachments
  String? content;
  PostTextContentType contentType;
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
    this.contentType = PostTextContentType.plaintext,
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

  Widget getCard(BuildContext context, {bool minified = false}) {
    ThemeData theme = Theme.of(context);
    bool repostOnly = repostOf != null && content == null;
    Post referencedPost = repostOnly ? repostOf! : this;
    TextStyle textContentStyle = theme.textTheme.bodyMedium!;
    return Card(
      margin: minified ? const EdgeInsetsDirectional.all(0) : null,
      shadowColor: minified ? Colors.transparent : null,
      shape: minified
          ? RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20), // if you need this
              side: BorderSide(
                color: Colors.grey.withOpacity(0.2),
                width: 1,
              ),
            )
          : null,
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: theme.colorScheme.primaryContainer,
          foregroundImage: referencedPost.user.avatarUrl != null
              ? NetworkImage(referencedPost.user.avatarUrl.toString())
              : null,
          radius: minified ? 16 : 20,
        ),
        subtitle:
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          if (referencedPost.content != null &&
              contentType == PostTextContentType.plaintext)
            Text(
              content!,
              style: textContentStyle,
            ),
          if (referencedPost.content != null &&
              contentType == PostTextContentType.html)
            Html(
              data: content!,
              style: {
                "a": Style(color: theme.colorScheme.secondary),
                "body": Style(
                    color: textContentStyle.color, margin: EdgeInsets.zero),
                "p": Style(margin: EdgeInsets.zero),
              },
            ),
          if (referencedPost.repostOf != null)
            referencedPost.repostOf!.getCard(context, minified: true),
        ]),
        title: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          if (repostOnly)
            user.getRenderedUsername(theme.textTheme.bodyMedium!,
                actionContext: UserActionContext.reposted),
          referencedPost.user.getRenderedUsername(theme.textTheme.bodyMedium!)
        ]),
      ),
    );
  }

  BigInt importMultipleReactions(Map<String, dynamic> data) {
    reactionCount = BigInt.zero;
    reactionTypes = {};
    for (var el in data.entries) {
      BigInt count = BigInt.parse(el.value.toString());
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
        res.replyCount = BigInt.tryParse(postInfo["replies_count"].toString());
      }
      if (postInfo.containsKey("reblogs_count")) {
        res.repostCount = BigInt.tryParse(postInfo["reblogs_count"].toString());
      }
      if (postInfo.containsKey("favourites_count")) {
        res.reactionCount =
            BigInt.tryParse(postInfo["favourites_count"].toString());
      }
      if (postInfo.containsKey("content")) {
        res.content = postInfo["content"];
        res.contentType = PostTextContentType.html;
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
      User user = User.fromMisskey(postInfo["user"])!;
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
        res.replyCount = BigInt.tryParse(postInfo["repliesCount"].toString());
      }
      if (postInfo.containsKey("renoteCount")) {
        res.repostCount = BigInt.tryParse(postInfo["renoteCount"].toString());
      }
      if (postInfo.containsKey("reactions") &&
          (postInfo["reactions"] as Map<dynamic, dynamic>).isNotEmpty) {
        res.importMultipleReactions(postInfo["reactions"] as Map<String, int>);
      }
      if (postInfo.containsKey("text")) {
        res.content = postInfo["text"];
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

enum PostTextContentType {
  html,
  markdown,
  plaintext,
}

enum PostVisibility {
  public,
  unlisted,
  private,
  direct,
}
