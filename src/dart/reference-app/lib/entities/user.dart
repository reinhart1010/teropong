import 'package:enum_to_string/enum_to_string.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';

class User {
  String? avatarBlurHash, bio, coverBlurHash, displayName;
  Uri? avatarUrl, coverUrl, staticAvatarUrl, staticCoverUrl, url;
  DateTime? createdAt;
  BigInt? followerCount, followingCount, postCount;
  String host, username;
  late Map<String, String> internalIds;
  bool isAdmin, isBot, isCat, isLocked, isModerator;
  UserOnlineStatus onlineStatus;

  User({
    this.avatarBlurHash,
    this.avatarUrl,
    this.bio,
    this.createdAt,
    this.coverBlurHash,
    this.coverUrl,
    this.displayName,
    this.followerCount,
    this.followingCount,
    required this.host,
    Map<String, String>? internalIds,
    this.isAdmin = false,
    this.isBot = false,
    this.isCat = false,
    this.isLocked = false,
    this.isModerator = false,
    this.onlineStatus = UserOnlineStatus.unknown,
    this.postCount,
    this.url,
    required this.username,
    this.staticAvatarUrl,
    this.staticCoverUrl,
  }) {
    this.internalIds = internalIds ?? {};
  }

  RichText getRenderedUsername(TextStyle baseStyle,
      {UserActionContext? actionContext}) {
    List<InlineSpan> spans = [];

    if (actionContext != null) {
      IconData actionIcon;
      switch (actionContext) {
        case UserActionContext.followed:
          actionIcon = FluentIcons.person_add_16_filled;
          break;
        case UserActionContext.liked:
          actionIcon = FluentIcons.heart_16_filled;
          break;
        case UserActionContext.reposted:
          actionIcon = FluentIcons.arrow_repeat_all_16_filled;
          break;
      }
      spans.addAll(
        [
          WidgetSpan(
            child: Icon(
              actionIcon,
              size: baseStyle.fontSize,
            ),
          ),
          WidgetSpan(
            child: SizedBox(
              width: baseStyle.fontSize != null
                  ? baseStyle.fontSize! * 2 / 3
                  : null,
            ),
          ),
          TextSpan(
              style: baseStyle.copyWith(fontWeight: FontWeight.w700),
              text: displayName ?? "@$username@$host")
        ],
      );
    } else {
      spans.addAll([
        TextSpan(
            style: baseStyle.copyWith(fontWeight: FontWeight.w700),
            text: displayName ?? "@$username@$host"),
        if (displayName != null)
          WidgetSpan(
            child: SizedBox(
              width:
                  baseStyle.fontSize != null ? baseStyle.fontSize! / 4 : null,
            ),
          ),
        if (displayName != null)
          TextSpan(
            style: baseStyle.copyWith(
              fontSize:
                  baseStyle.fontSize != null ? 0.9 * baseStyle.fontSize! : null,
              fontWeight: FontWeight.w400,
            ),
            text: "@$username@$host",
          ),
      ]);
    }

    if (isAdmin || isModerator || isLocked || isBot || isCat) {
      spans.addAll([
        WidgetSpan(
          child: SizedBox(
            width: baseStyle.fontSize != null ? baseStyle.fontSize! / 4 : null,
          ),
        ),
        if (isAdmin)
          TextSpan(
            style: baseStyle,
          ),
        if (isModerator)
          TextSpan(
            style: baseStyle,
            text: "👨‍⚖️",
          ),
        if (isLocked)
          TextSpan(
            style: baseStyle,
            text: "🔒",
          ),
        if (isBot)
          TextSpan(
            style: baseStyle,
            text: "🤖",
          ),
        if (isCat)
          TextSpan(
            style: baseStyle,
            text: "😻",
          ),
      ]);
    }

    if (actionContext != null) {
      spans.addAll([
        WidgetSpan(
          child: SizedBox(
            width: baseStyle.fontSize != null ? baseStyle.fontSize! / 4 : null,
          ),
        ),
        TextSpan(
          style: baseStyle.copyWith(
            fontSize:
                baseStyle.fontSize != null ? 0.8 * baseStyle.fontSize! : null,
            fontWeight: FontWeight.w400,
          ),
          text: actionContext.name,
        ),
      ]);
    }

    return RichText(text: TextSpan(children: spans));
  }

  static User? fromProfileUrl(Uri profileUrl) {
    try {
      return User(
        host: profileUrl.host,
        username: profileUrl.pathSegments.last.replaceFirst("@", ""),
      );
    } catch (e) {
      return null;
    }
  }
}

enum UserActionContext {
  liked,
  followed,
  reposted,
}

enum UserOnlineStatus {
  unknown,
  online,
  active,
  offline,
}
