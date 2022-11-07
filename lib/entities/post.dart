import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:badges/badges.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:octo_image/octo_image.dart';
import 'package:teropong/entities/service.dart';
import 'package:teropong/entities/user.dart';

import 'activitypub.dart';

class Post {
  PostAppSource? appSource;
  //TODO: Add Attachments
  String? content;
  PostTextContentType contentType;
  DateTime? createdAt, updatedAt;
  bool isSensitive;
  Map<String, String> internalIds = <String, String>{};
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
    Map<String, String>? internalIds,
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
  }) {
    if (internalIds != null) {
      this.internalIds = internalIds;
    }
    if (reactionTypes != null) {
      reactionCount = BigInt.zero;
      for (var element in reactionTypes!.entries) {
        reactionCount = reactionCount! + element.value;
      }
    }
  }

  Widget buildCard(BuildContext context, {bool embedded = false}) {
    MediaQueryData mediaQuery = MediaQuery.of(context);
    bool isMobile = mediaQuery.size.width < 600;
    ThemeData theme = Theme.of(context);
    bool repostOnly = repostOf != null && content == null;
    Post referencedPost = repostOnly ? repostOf! : this;
    TextStyle textContentStyle = theme.textTheme.bodyMedium!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        buildProfileBanner(context, embedded: embedded),
        Padding(
          padding: embedded
              ? const EdgeInsets.all(0)
              : const EdgeInsetsDirectional.fromSTEB(54, 0, 8, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (content != null && content!.isNotEmpty) buildContent(context),
              if (repostOf != null)
                Card(
                  shadowColor: Colors.transparent,
                  child: repostOf!.buildCard(context, embedded: true),
                ),
              if (!embedded && repostOf != null) const SizedBox(height: 8),
              if (!embedded)
                Row(
                  mainAxisAlignment: isMobile
                      ? MainAxisAlignment.spaceBetween
                      : MainAxisAlignment.start,
                  children: [
                    if (replyCount != null)
                      TextButton.icon(
                        icon: const Icon(FluentIcons.chat_20_regular),
                        label: Text(replyCount.toString()),
                        onPressed: () {},
                        // padding: const EdgeInsets.all(0),
                      ),
                    if (repostCount != null)
                      TextButton.icon(
                        icon:
                            const Icon(FluentIcons.arrow_repeat_all_20_regular),
                        label: Text(repostCount.toString()),
                        onPressed: () {},
                      ),
                    if (reactionCount != null)
                      TextButton.icon(
                        icon: const Icon(FluentIcons.heart_20_regular),
                        label: Text((reactionTypes != null &&
                                reactionTypes!.entries.isNotEmpty)
                            ? reactionTypes!.entries
                                .map((entry) => "${entry.key} ${entry.value}")
                                .toList()
                                .join(", ")
                            : reactionCount.toString()),
                        onPressed: () {},
                      ),
                    IconButton(
                      color: theme.colorScheme.primary,
                      icon: const Icon(FluentIcons.share_20_regular),
                      onPressed: () {},
                      padding: EdgeInsets.zero,
                    ),
                  ],
                ),
            ],
          ),
        ),
        if (!embedded) const Divider(),
      ],
    );
  }

  Widget buildContent(BuildContext context) {
    ThemeData theme = Theme.of(context);
    Widget child = const SizedBox();
    switch (contentType) {
      case PostTextContentType.plaintext:
        child = SelectableText(content ?? "Post unavailable");
        break;
      case PostTextContentType.html:
        child = SelectableHtml(
          data: content,
          style: {
            "a": Style(color: theme.colorScheme.primary),
          },
        );
        break;
      case PostTextContentType.markdown:
        child = MarkdownBody(
          data: content!,
          selectable: true,
        );
        break;
    }
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
      child: child,
    );
  }

  Widget buildProfileBanner(BuildContext context, {bool embedded = false}) {
    ThemeData theme = Theme.of(context);
    List<IconData> userAttributions = [];
    if (user.isBot) {
      userAttributions.add(FluentIcons.bot_20_regular);
    }
    if (user.isCat) {
      userAttributions.add(FluentIcons.animal_cat_16_regular);
    }
    if (user.isAdmin || user.isModerator) {
      userAttributions.add(FluentIcons.shield_20_regular);
    }
    final Widget profileImage = OctoImage.fromSet(
      fit: BoxFit.cover,
      height: embedded ? 36 : 48,
      image: NetworkImage(
        user.avatarUrl.toString(),
      ),
      octoSet: OctoSet.circleAvatar(
        backgroundColor: theme.colorScheme.primaryContainer,
        text: Text((user.displayName != null && user.displayName!.isNotEmpty)
            ? user.displayName!.substring(0, 1)
            : user.username.substring(0, 1)),
      ),
      width: embedded ? 36 : 48,
    );
    String subtitleText = "";
    if (user.displayName != null && user.displayName!.isNotEmpty) {
      subtitleText += "@${user.username}@${user.host}";
    }
    if (!embedded && internalIds.entries.isNotEmpty) {
      if (subtitleText.isNotEmpty) {
        subtitleText += "\n";
      }
      subtitleText += "Retrieved from ${internalIds.entries.first.key}";
    }

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 8),
      horizontalTitleGap: 4,
      leading: userAttributions.isNotEmpty
          ? Badge(
              badgeContent: Row(
                  children: userAttributions
                      .map((el) => Icon(
                            el,
                            color: theme.colorScheme.onPrimary,
                            size: 16,
                          ))
                      .toList()),
              badgeColor: theme.colorScheme.primary,
              borderRadius: const BorderRadius.all(Radius.circular(16)),
              padding: const EdgeInsets.all(2),
              position: embedded
                  ? const BadgePosition(end: -8, top: -8)
                  : const BadgePosition(end: -2, top: -2),
              shape: BadgeShape.square,
              child: profileImage,
            )
          : profileImage,
      minLeadingWidth: embedded ? 48 : 54,
      subtitle: (subtitleText.isNotEmpty)
          ? Text(
              subtitleText,
              softWrap: true,
            )
          : null,
      title: Text(
        (user.displayName != null && user.displayName!.isNotEmpty)
            ? user.displayName!
            : "@${user.username}@${user.host}",
        softWrap: true,
      ),
      trailing: !embedded
          ? Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(FluentIcons.info_20_regular),
                  onPressed: () {},
                  padding: const EdgeInsets.all(0),
                ),
                IconButton(
                  icon: const Icon(FluentIcons.more_circle_20_regular),
                  onPressed: () {},
                  padding: const EdgeInsets.all(0),
                )
              ],
            )
          : null,
    );
  }

  Future<String?> getInternalIdByHostname(
    String hostname, {
    bool fetchIfUnavailable = false,
    Service? hostnameService,
    bool updateAttachmentsDuringFetch = false,
  }) async {
    String? res = internalIds[hostname];
    // if (res != null || !fetchIfUnavailable) {
    //   return res;
    // }
    // Instance? instance = await Instance.of(Uri(host: hostname));
    // if (instance != null) {
    //   Post? post =
    // }

    return res;
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
}

class PostAppSource {
  String name;
  Uri url;
  PostAppSource(this.name, this.url);
}

abstract class PostAttachment {
  String? get blurhash;
  String? get description;
  Map<String, String> get internalIds;
  Uri? get previewUrl;
  Uri? get remoteUrl;
  Uri? get shortUrl;
  Uri? get sourceUrl;
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
