import 'package:enum_to_string/enum_to_string.dart';
import 'package:teropong/entities/instance.dart';

class User {
  Uri? avatarUrl, coverUrl, staticAvatarUrl, staticCoverUrl, url;
  String? bio, displayName;
  DateTime? createdAt;
  BigInt? followerCount, followingCount, postCount;
  String host, username;
  late Map<String, String> internalIds;
  bool isBot, isCat, isLocked;
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
    this.isBot = false,
    this.isCat = false,
    this.isLocked = false,
    this.onlineStatus = UserOnlineStatus.unknown,
    this.postCount,
    this.url,
    required this.username,
    this.staticAvatarUrl,
    this.staticCoverUrl,
  }) {
    this.internalIds = internalIds ?? {};
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
      User res = User.fromProfileUrl(userInfo["url"])!;
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
      if (userInfo.containsKey("followers_count")) {
        res.followerCount = BigInt.tryParse(userInfo["followers_count"]);
      }
      if (userInfo.containsKey("following_count")) {
        res.followingCount = BigInt.tryParse(userInfo["following_count"]);
      }
      if (userInfo.containsKey("statuses_count")) {
        res.postCount = BigInt.tryParse(userInfo["statuses_count"]);
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
      if (userInfo.containsKey("name")) {
        res.displayName = userInfo["name"];
      }
      if (userInfo.containsKey("avatarUrl")) {
        res.avatarUrl = Uri.tryParse(userInfo["avatarUrl"]);
        res.staticAvatarUrl = Uri.tryParse(userInfo["avatarUrl"]);
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

enum UserOnlineStatus {
  unknown,
  online,
  active,
  offline,
}
