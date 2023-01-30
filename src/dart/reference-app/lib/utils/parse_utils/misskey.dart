import 'package:dio/dio.dart';
import 'package:enum_to_string/enum_to_string.dart';
import 'package:teropong/entities/account.dart';
import 'package:teropong/entities/activitypub.dart';
import 'package:teropong/entities/instance.dart';
import 'package:teropong/entities/post.dart';
import 'package:teropong/entities/user.dart';
import 'package:teropong/utils/parse_utils.dart';

class MisskeyParseUtils extends ParseUtils {
  MisskeyParseUtils(super.service);

  @override
  Future<InstanceRegistrationPolicy?> parseInstanceRegistrationPolicy(
      dynamic serverData) async {
    try {
      Map<String, dynamic> parsedData = serverData as Map<String, dynamic>;
      InstanceRegistrationPolicy res = InstanceRegistrationPolicy();
      // If the server is closed for registration, Misskey still requires a dedicated invite code
      res.openForSignups = true;
      res.requiresInviteCode = !parsedData.containsKey("disableRegistration") ||
          parsedData["disableRegistration"] == false;
      if (parsedData.containsKey("emailRequiredForSignup")) {
        res.requiresEmail = parsedData["emailRequiredForSignup"] == true;
      }
      if ((parsedData.containsKey("enableHcaptcha") &&
              parsedData["enableHcaptcha"] == true) ||
          (parsedData.containsKey("enableRecaptcha") &&
              parsedData["enableRecaptcha"] == true)) {
        res.requiresCaptcha = true;
      }
      return res;
    } catch (_) {
      return null;
    }
  }

  // Note: [serverData] is not
  @override
  Future<InstanceStats?> parseInstanceStats(dynamic serverData) async {
    try {
      Map<String, dynamic> parsedData = serverData as Map<String, dynamic>;
      InstanceStats stats = InstanceStats();
      if (parsedData.containsKey("instances")) {
        stats.peers = BigInt.tryParse(parsedData["instances"].toString());
      }
      if (parsedData.containsKey("originalNotesCount")) {
        stats.posts =
            BigInt.tryParse(parsedData["originalNotesCount"].toString());
      }
      if (parsedData.containsKey("originalUsersCount")) {
        stats.users =
            BigInt.tryParse(parsedData["originalUsersCount"].toString());
      }
      return (stats.peers == null && stats.posts == null && stats.users == null)
          ? null
          : stats;
    } on DioError catch (_) {
      return null;
    }
  }

  @override
  Future<Post?> parsePost(dynamic postData, Account referenceAccount) async {
    if (service.currentInstance == null) {
      return null;
    }
    try {
      Map<String, dynamic> postInfo = postData as Map<String, dynamic>;
      Instance instance = service.currentInstance!;
      Uri uri = Uri.parse(postInfo["uri"]);
      User user = (await parseUser(postInfo["user"]))!;
      Post res = Post(
        internalIds: {instance.instanceUrl.host: postInfo["id"].toString()},
        type: ActivityType.note,
        contentType: PostTextContentType.markdown,
        uri: uri,
        user: user,
      );
      if (referenceAccount.user != null) {
        res.internalReferenceAccounts = {
          "@${referenceAccount.user!.username}@${instance.instanceUrl.host}":
              referenceAccount
        };
      }
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
      if (postInfo.containsKey("reactions")) {
        if ((postInfo["reactions"] as Map<dynamic, dynamic>).isNotEmpty) {
          res.importMultipleReactions(
              postInfo["reactions"] as Map<String, int>);
        } else {
          res.reactionCount = BigInt.zero;
          res.reactionTypes = {};
        }
      }
      if (postInfo.containsKey("text")) {
        res.content = postInfo["text"];
      }
      if (postInfo.containsKey("reply")) {
        res.replyOf = await parsePost(postInfo["reply"], referenceAccount);
      }
      if (postInfo.containsKey("renote")) {
        res.repostOf = await parsePost(postInfo["renote"], referenceAccount);
      }
      if (postInfo.containsKey("files")) {
        List<dynamic> attachments = postInfo["files"] as List<dynamic>;
        for (dynamic attachment in attachments) {
          PostAttachment? insert = await parsePostAttachment(attachment);
          if (insert != null) {
            res.attachments.add(insert);
          }
        }
      }
      return res;
    } catch (e) {
      return null;
    }
  }

  @override
  Future<PostAttachment?> parsePostAttachment(dynamic attachmentData) async {
    try {
      Map<String, dynamic> attachmentInfo =
          attachmentData as Map<String, dynamic>;
      Instance instance = service.currentInstance!;
      PostAttachment res = PostAttachment(
        internalIds: {
          instance.instanceUrl.host: attachmentInfo["id"].toString()
        },
        mime: attachmentInfo["type"],
        previewUrl: Uri.parse(attachmentInfo["thumbnailUrl"]),
        sourceUrl: Uri.parse(attachmentInfo["url"]),
      );
      if (attachmentInfo["type"].toString().startsWith("image/")) {
        res.type = PostAttachmentType.image;
      }
      if (attachmentInfo.containsKey("blurhash")) {
        res.blurhash = attachmentInfo["blurhash"];
      }
      if (attachmentInfo.containsKey("comment")) {
        res.description = attachmentInfo["comment"];
      }
      if (attachmentInfo.containsKey("md5")) {
        res.md5 = attachmentInfo["md5"];
      }
      return res;
    } catch (e) {
      return null;
    }
  }

  @override
  Future<User?> parseUser(userData) async {
    try {
      Map<String, dynamic> userInfo = userData as Map<String, dynamic>;
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
