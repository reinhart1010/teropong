import 'package:enum_to_string/enum_to_string.dart';
import 'package:teropong/entities/activitypub.dart';
import 'package:teropong/entities/instance.dart';
import 'package:teropong/entities/post.dart';
import 'package:teropong/entities/user.dart';
import 'package:teropong/utils/parse_utils.dart';

class MastodonParseUtils extends ParseUtils {
  MastodonParseUtils(super.service);

  @override
  Future<InstanceRegistrationPolicy?> parseInstanceRegistrationPolicy(
      dynamic serverData) async {
    try {
      Map<String, dynamic> parsedData = serverData as Map<String, dynamic>;
      InstanceRegistrationPolicy res = InstanceRegistrationPolicy();
      if (parsedData.containsKey("registrations")) {
        res.openForSignups = parsedData["registrations"] == true;
      }
      if (parsedData.containsKey("approval_required")) {
        res.requiresApproval = parsedData["approval_required"] == true;
      }
      return res;
    } catch (_) {
      return null;
    }
  }

  @override
  Future<InstanceStats?> parseInstanceStats(dynamic serverData) async {
    try {
      Map<String, dynamic> parsedData = serverData as Map<String, dynamic>;
      InstanceStats res = InstanceStats();
      if (parsedData.containsKey("domain_count")) {
        res.peers = BigInt.tryParse(parsedData["domain_count"].toString());
      }
      if (parsedData.containsKey("status_count")) {
        res.posts = BigInt.tryParse(parsedData["status_count"].toString());
      }
      if (parsedData.containsKey("user_count")) {
        res.users = BigInt.tryParse(parsedData["user_count"].toString());
      }
      return (res.peers == null && res.posts == null && res.users == null)
          ? null
          : res;
    } catch (_) {
      return null;
    }
  }

  @override
  Future<Post?> parsePost(dynamic postData) async {
    if (service.currentInstance == null) {
      return null;
    }
    try {
      Map<String, dynamic> postInfo = postData as Map<String, dynamic>;
      Instance instance = service.currentInstance!;
      Uri uri = Uri.parse(postInfo["uri"]);
      User user = (await parseUser(postInfo["account"]))!;
      Post res = Post(
        internalIds: {instance.instanceUrl.host: postInfo["id"].toString()},
        type: ActivityType.note,
        uri: uri,
        user: user,
      );
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
        res.repostOf = await parsePost(postInfo["reblog"]);
      }
      return res;
    } catch (e) {
      return null;
    }
  }

  @override
  Future<User?> parseUser(dynamic userData) async {
    try {
      Map<String, dynamic> userInfo = userData as Map<String, dynamic>;
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
}
