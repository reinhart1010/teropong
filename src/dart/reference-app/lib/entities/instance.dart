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

  static Future<InstanceRegistrationPolicy?> from(
          dynamic serverData, Instance instance) async =>
      instance.service != null
          ? (await instance.service!.parseUtils
              .parseInstanceRegistrationPolicy(serverData))
          : null;
}

class InstanceStats {
  BigInt? peers, posts, users;
  InstanceStats({this.peers, this.posts, this.users});
}
