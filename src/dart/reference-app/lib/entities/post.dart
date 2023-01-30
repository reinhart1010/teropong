import 'package:badges/badges.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:detectable_text_field/detector/sample_regular_expressions.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:octo_image/octo_image.dart';
import 'package:teropong/entities/account.dart';
import 'package:teropong/entities/instance.dart';
import 'package:teropong/entities/service.dart';
import 'package:teropong/entities/service/misskey.dart';
import 'package:teropong/entities/user.dart';
import 'package:teropong/layouts/deck/list.dart';
import 'package:teropong/main.dart';
import 'package:url_launcher/url_launcher.dart';

import 'activitypub.dart';

class Post {
  PostAppSource? appSource;
  List<PostAttachment> attachments = [];
  String? content;
  PostTextContentType contentType;
  DateTime? createdAt, updatedAt;
  bool isSensitive;
  Map<String, String> internalIds = {};
  Map<String, Account> internalReferenceAccounts = {};
  BigInt? reactionCount, replyCount, repostCount;
  Map<String, BigInt>? reactionTypes;
  Post? replyOf, repostOf;
  ActivityType type;
  Uri uri;
  User user;
  PostVisibility visibility;

  Post({
    this.appSource,
    List<PostAttachment>? attachments,
    this.content,
    this.contentType = PostTextContentType.plaintext,
    this.createdAt,
    Map<String, String>? internalIds,
    Map<String, Account>? internalReferenceAccounts,
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
    if (attachments != null) {
      this.attachments = attachments;
    }
    if (internalIds != null) {
      this.internalIds = internalIds;
    }
    if (internalReferenceAccounts != null) {
      this.internalReferenceAccounts = internalReferenceAccounts;
    }
    if (reactionTypes != null) {
      reactionCount = BigInt.zero;
      for (var element in reactionTypes!.entries) {
        reactionCount = reactionCount! + element.value;
      }
    }
  }

  Widget buildAttachments(BuildContext context, {bool embedded = false}) {
    List<PostAttachment> featuredImagesOrVideos = [], nonFeatured = [];
    int i = 0;
    for (PostAttachment attachment in attachments) {
      if (attachment.type == PostAttachmentType.image ||
          attachment.type == PostAttachmentType.video && i < 4) {
        featuredImagesOrVideos.add(attachment);
        i++;
      } else {
        nonFeatured.add(attachment);
      }
    }
    Widget renderImage(int index, double aspectRatio) {
      return AspectRatio(
        aspectRatio: aspectRatio,
        child: OctoImage.fromSet(
          fit: BoxFit.cover,
          image: CachedNetworkImageProvider(
              (featuredImagesOrVideos[index].sourceUrl).toString()),
          octoSet: featuredImagesOrVideos[index].blurhash != null
              ? OctoSet.blurHash(featuredImagesOrVideos[index].blurhash!)
              : OctoSet.circularIndicatorAndIcon(showProgress: true),
        ),
      );
    }

    List<Widget> contents = [];
    if (i > 0) {
      if (i == 1) {
        contents.add(
          Container(
            constraints: !embedded ? const BoxConstraints(maxWidth: 411) : null,
            child: Card(
              clipBehavior: Clip.hardEdge,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(embedded ? 10 : 12)),
              child: renderImage(0, 4 / 3),
            ),
          ),
        );
      } else if (i == 2) {
        contents.add(
          Container(
            constraints: !embedded ? const BoxConstraints(maxWidth: 548) : null,
            child: Card(
              clipBehavior: Clip.hardEdge,
              child: Row(
                children: [
                  renderImage(0, 3 / 4),
                  const SizedBox(width: 8),
                  renderImage(1, 3 / 4),
                ],
              ),
            ),
          ),
        );
      } else if (i == 3) {
        contents.add(
          Container(
            constraints: !embedded ? const BoxConstraints(maxWidth: 548) : null,
            child: Card(
              clipBehavior: Clip.hardEdge,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  renderImage(0, 3 / 4),
                  const SizedBox(width: 8),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      renderImage(1, 3 / 4),
                      const SizedBox(height: 8),
                      renderImage(2, 3 / 4),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      } else {
        contents.add(
          Container(
            constraints: !embedded ? const BoxConstraints(maxWidth: 548) : null,
            child: Row(
              children: [
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    renderImage(0, 3 / 4),
                    const SizedBox(height: 8),
                    renderImage(1, 3 / 4),
                  ],
                ),
                const SizedBox(width: 8),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    renderImage(2, 3 / 4),
                    const SizedBox(height: 8),
                    renderImage(3, 3 / 4),
                  ],
                ),
              ],
            ),
          ),
        );
      }
    }
    return Column(
      children: contents,
    );
  }

  Widget buildCard(
    BuildContext context, {
    bool embedded = false,
    bool minifyProfile = false,
  }) =>
      PostWidget(this, embedded: embedded, minifyProfile: minifyProfile);

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
          onLinkTap: (String? url, RenderContext context,
              Map<String, String> attributes, element) {
            if (url != null) {
              launchUrl(Uri.parse(url));
            }
          },
          style: {
            "a": Style(
              color: Colors.lightBlue,
              textDecoration: TextDecoration.underline,
            ),
          },
        );
        break;
      case PostTextContentType.markdown:
        child = MarkdownBody(
          data: content!,
          onTapLink: (String text, String? href, String title) {
            if (href != null) {
              launchUrl(Uri.parse(href));
            }
          },
          selectable: true,
          styleSheet: MarkdownStyleSheet(
            a: theme.textTheme.bodyMedium!.copyWith(
              color: Colors.lightBlue,
              decoration: TextDecoration.underline,
            ),
          ),
        );
        break;
    }
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
      child: child,
    );
  }

  Widget buildProfileBanner(
    BuildContext context, {
    bool embedded = false,
    bool minifyProfile = false,
  }) {
    ThemeData theme = Theme.of(context);
    if (minifyProfile) {
      return ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 8),
        dense: true,
        title: user.getRenderedUsername(theme.textTheme.bodyMedium!),
      );
    }
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
      image: CachedNetworkImageProvider(
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

  Future<List<Post>> fetchReplies() {}

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

  Future<bool> react(Account account, {String emoji = '👍'}) async {
    if (!internalIds.containsKey(account.instance.instanceUrl.host)) {
      return false;
    } else {
      await account.instance.service!.react(
        account,
        internalIds[account.instance.instanceUrl.host].toString(),
        emoji: emoji,
      );
      return true;
    }
  }
}

class PostAppSource {
  String name;
  Uri url;
  PostAppSource(this.name, this.url);
}

class PostAttachment {
  String? blurhash, description, md5, mime, sha1;
  Map<String, String> internalIds;
  Uri? previewUrl, remoteUrl, shortUrl;
  Uri sourceUrl;
  PostAttachmentType type;

  PostAttachment({
    this.blurhash,
    this.description,
    required this.internalIds,
    this.md5,
    this.mime,
    this.previewUrl,
    this.remoteUrl,
    this.sha1,
    this.shortUrl,
    this.type = PostAttachmentType.unknown,
    required this.sourceUrl,
  });
}

enum PostAttachmentType { unknown, image, audio, video }

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

class PostWidget extends StatefulWidget {
  final bool embedded, minifyProfile;
  final Post post;
  const PostWidget(
    this.post, {
    this.embedded = false,
    super.key,
    this.minifyProfile = false,
  });
  @override
  State createState() => PostWidgetState();
}

class PostWidgetState extends State<PostWidget> {
  bool _isSensitiveContentWarningConsent = false;

  @override
  Widget build(BuildContext context) {
    MediaQueryData mediaQuery = MediaQuery.of(context);
    NavigatorState navigator = Navigator.of(context);
    bool isMobile = mediaQuery.size.width < 600;
    ThemeData theme = Theme.of(context);
    bool repostOnly =
        widget.post.repostOf != null && widget.post.content == null;
    TextStyle textContentStyle = theme.textTheme.bodyMedium!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        widget.post.buildProfileBanner(context,
            embedded: widget.embedded, minifyProfile: widget.minifyProfile),
        Padding(
          padding: widget.embedded
              ? const EdgeInsets.all(0)
              : const EdgeInsetsDirectional.fromSTEB(54, 0, 8, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (widget.post.replyOf != null)
                if (!widget.embedded)
                  Card(
                    shadowColor: Colors.transparent,
                    child: widget.post.replyOf!.buildCard(context,
                        embedded: true, minifyProfile: true),
                  )
                else
                  Row(
                    children: [
                      Text(
                          "Replied to @${widget.post.replyOf!.user.username}@${widget.post.replyOf!.user.host}"),
                    ],
                  ),
              if (widget.post.content != null &&
                  widget.post.content!.isNotEmpty)
                widget.post.buildContent(context),
              if (widget.post.repostOf != null)
                if (!widget.embedded)
                  Card(
                    shadowColor: Colors.transparent,
                    child: widget.post.repostOf!
                        .buildCard(context, embedded: true),
                  )
                else
                  Row(
                    children: [
                      Text(
                          "Reposted @${widget.post.repostOf!.user.username}@${widget.post.repostOf!.user.host}"),
                    ],
                  ),
              if (widget.post.attachments.isNotEmpty)
                widget.post
                    .buildAttachments(context, embedded: widget.embedded),
              if (!widget.embedded && widget.post.repostOf != null)
                const SizedBox(height: 8),
              if (!widget.embedded)
                Row(
                  mainAxisAlignment: isMobile
                      ? MainAxisAlignment.spaceBetween
                      : MainAxisAlignment.start,
                  children: [
                    if (widget.post.replyCount != null)
                      TextButton.icon(
                        icon: const Icon(FluentIcons.chat_20_regular),
                        label: Text(widget.post.replyCount.toString()),
                        onPressed: () {
                          navigator.pushNamed(
                            "/post",
                            arguments: CommonPageArguments(post: widget.post),
                          );
                        },
                        // padding: const EdgeInsets.all(0),
                      ),
                    if (widget.post.repostCount != null)
                      TextButton.icon(
                        icon:
                            const Icon(FluentIcons.arrow_repeat_all_20_regular),
                        label: Text(widget.post.repostCount.toString()),
                        onPressed: () {},
                      ),
                    if (widget.post.reactionCount != null)
                      TextButton.icon(
                        icon: const Icon(FluentIcons.heart_20_regular),
                        label: Text((widget.post.reactionTypes != null &&
                                widget.post.reactionTypes!.entries.isNotEmpty)
                            ? widget.post.reactionTypes!.entries
                                .map((entry) => "${entry.key} ${entry.value}")
                                .toList()
                                .join(", ")
                            : widget.post.reactionCount.toString()),
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
        if (!widget.embedded) const Divider(),
      ],
    );
  }
}
