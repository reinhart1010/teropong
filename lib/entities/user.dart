import 'package:enum_to_string/enum_to_string.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';

class User {
  Uri? avatarUrl, coverUrl, staticAvatarUrl, staticCoverUrl, url;
  String? bio, displayName;
  DateTime? createdAt;
  BigInt? followerCount, followingCount, postCount;
  String host, username;
  late Map<String, String> internalIds;
  bool isAdmin, isBot, isCat, isLocked, isModerator;
  UserOnlineStatus onlineStatus;

  User({
    this.avatarUrl,
    this.bio,
    this.createdAt,
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

  static User? fromMastodon(dynamic data) {
    try {
      Map<String, dynamic> userInfo = data as Map<String, dynamic>;
      User res = User.fromProfileUrl(Uri.parse(userInfo["url"]))!;
      if (userInfo.containsKey("display_name")) {
        res.displayName = userInfo["display_name"];
      }
      if (userInfo.containsKey("note")) {
        res.bio = userInfo["note"];
      }
      if (userInfo.containsKey("created_at")) {
        res.createdAt = DateTime.tryParse(userInfo["created_at"]);
      }
      if (userInfo.containsKey("avatar")) {
        res.avatarUrl = Uri.tryParse(userInfo["avatar"]);
      }
      if (userInfo.containsKey("avatar_static")) {
        res.staticAvatarUrl = Uri.tryParse(userInfo["avatar_static"]);
      }
      if (userInfo.containsKey("header")) {
        res.coverUrl = Uri.tryParse(userInfo["header"]);
      }
      if (userInfo.containsKey("header_static")) {
        res.staticCoverUrl = Uri.tryParse(userInfo["header_static"]);
      }
      if (userInfo.containsKey("locked")) {
        res.isLocked = userInfo["locked"] == true;
      }
      if (userInfo.containsKey("bot")) {
        res.isBot = userInfo["bot"] == true;
      }
      if (userInfo.containsKey("followers_count")) {
        res.followerCount =
            BigInt.tryParse(userInfo["followers_count"].toString());
      }
      if (userInfo.containsKey("following_count")) {
        res.followingCount =
            BigInt.tryParse(userInfo["following_count"].toString());
      }
      if (userInfo.containsKey("statuses_count")) {
        res.postCount = BigInt.tryParse(userInfo["statuses_count"].toString());
      }
      return res;
    } catch (e) {
      return null;
    }
  }

  static User? fromMisskey(dynamic data) {
    try {
      Map<String, dynamic> userInfo = data as Map<String, dynamic>;
      User res = User(host: userInfo["host"], username: userInfo["username"]);
      if (userInfo.containsKey("name") && userInfo["name"].length > 0) {
        res.displayName = userInfo["name"];
      }
      if (userInfo.containsKey("avatarUrl")) {
        res.avatarUrl = Uri.tryParse(userInfo["avatarUrl"]);
        res.staticAvatarUrl = Uri.tryParse(userInfo["avatarUrl"]);
      }
      if (userInfo.containsKey("isAdmin")) {
        res.isAdmin = userInfo["isAdmin"] == true;
      }
      if (userInfo.containsKey("isModerator")) {
        res.isModerator = userInfo["isModerator"] == true;
      }
      if (userInfo.containsKey("isBot")) {
        res.isBot = userInfo["isBot"] == true;
      }
      if (userInfo.containsKey("isCat")) {
        res.isCat = userInfo["isCat"] == true;
      }
      if (userInfo.containsKey("onlineStatus") &&
          EnumToString.fromString(
                  UserOnlineStatus.values, userInfo["onlineStatus"]) !=
              null) {
        res.onlineStatus = EnumToString.fromString(
            UserOnlineStatus.values, userInfo["onlineStatus"])!;
      }
      return res;
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
