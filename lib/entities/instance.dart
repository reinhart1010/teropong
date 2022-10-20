import 'package:dio/dio.dart';

import 'service.dart';
import 'service/mastodon.dart';
import 'service/misskey.dart';

class Instance {
  Uri instanceUrl;
  InstanceRegistrationPolicy? registrationPolicy;
  Service? service;
  InstanceStats? stats;
  String? title;

  Instance(
    this.instanceUrl,
    this.service, {
    this.stats,
    this.registrationPolicy,
    this.title,
  }) {
    if (title == null && service != null) {
      title = service!.name;
    }
  }

  static Future<Instance?> of(Uri instanceUrl, {Service? service}) async {
    if (service != null) return service.getInstance(instanceUrl);
    Instance? res;
    List<Future<Instance?> Function(Uri instanceUrl)> getInstanceFunctions = [
      MastodonService().getInstance,
      MisskeyService().getInstance,
    ];
    int i = 0;
    while (i < getInstanceFunctions.length && res == null) {
      res = await getInstanceFunctions[i](instanceUrl);
      i++;
    }
    return res;
  }
}

class InstanceRegistrationPolicy {
  bool openForSignups,
      requiresApproval,
      requiresCaptcha,
      requiresEmail,
      requiresInviteCode;

  InstanceRegistrationPolicy({
    this.openForSignups = false,
    this.requiresApproval = false,
    this.requiresCaptcha = false,
    this.requiresEmail = false,
    this.requiresInviteCode = false,
  });

  static InstanceRegistrationPolicy? fromMastodon(dynamic data) {
    try {
      Map<String, dynamic> parsedData = data as Map<String, dynamic>;
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

  static InstanceRegistrationPolicy? fromMisskey(dynamic data) {
    try {
      Map<String, dynamic> parsedData = data as Map<String, dynamic>;
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
}

class InstanceStats {
  BigInt? peers, posts, users;
  InstanceStats({this.peers, this.posts, this.users});

  static InstanceStats? fromMastodon(dynamic data) {
    try {
      Map<String, dynamic> parsedData = data as Map<String, dynamic>;
      InstanceStats res = InstanceStats();
      if (parsedData.containsKey("domain_count")) {
        res.peers = BigInt.tryParse(parsedData["domain_count"]);
      }
      if (parsedData.containsKey("status_count")) {
        res.posts = BigInt.tryParse(parsedData["status_count"]);
      }
      if (parsedData.containsKey("user_count")) {
        res.users = BigInt.tryParse(parsedData["user_count"]);
      }
      return (res.peers == null && res.posts == null && res.users == null)
          ? null
          : res;
    } catch (_) {
      return null;
    }
  }

  static Future<InstanceStats?> fromMisskey(Uri instanceUrl) async {
    Dio dio = Dio();
    try {
      Response res =
          await dio.post(instanceUrl.resolve("/api/stats").toString());
      Map<String, dynamic> serverInfo = res.data as Map<String, dynamic>;
      InstanceStats stats = InstanceStats();
      if (serverInfo.containsKey("instances")) {
        stats.peers = BigInt.tryParse(serverInfo["instances"]);
      }
      if (serverInfo.containsKey("originalNotesCount")) {
        stats.posts = BigInt.tryParse(serverInfo["originalNotesCount"]);
      }
      if (serverInfo.containsKey("originalUsersCount")) {
        stats.users = BigInt.tryParse(serverInfo["originalUsersCount"]);
      }
      return (stats.peers == null && stats.posts == null && stats.users == null)
          ? null
          : stats;
    } on DioError catch (_) {
      return null;
    }
  }
}
