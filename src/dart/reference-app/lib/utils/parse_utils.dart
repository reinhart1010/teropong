import 'package:teropong/entities/account.dart';
import 'package:teropong/entities/instance.dart';
import 'package:teropong/entities/post.dart';
import 'package:teropong/entities/service.dart';
import 'package:teropong/entities/user.dart';

abstract class ParseUtils {
  final Service service;

  ParseUtils(this.service);

  Future<InstanceRegistrationPolicy?> parseInstanceRegistrationPolicy(
      dynamic serverData);
  Future<InstanceStats?> parseInstanceStats(dynamic serverData);
  Future<Post?> parsePost(dynamic postData, Account originalAccount);
  Future<PostAttachment?> parsePostAttachment(dynamic attachmentData);
  Future<User?> parseUser(dynamic userData);
}
